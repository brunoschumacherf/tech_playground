class ImportFileSerializer < ActiveModel::Serializer
  attributes :info, :summary, :by_area, :sentiment_analysis, :eda, :ai_insights, :sentiment_details

  def info
    {
      id: object.id,
      name: object.name,
      status: object.status,
      created_at: object.created_at
    }
  end

  def summary
    feedbacks = object.employee_feedbacks
    return {} if feedbacks.empty?

    {
      total_responses: feedbacks.count,
      enps_score: calculate_enps(feedbacks),
      favorability: calculate_favorability(feedbacks)
    }
  end

  def by_area
    object.employee_feedbacks.group(:area).average(:feedback).transform_keys do |key|
      I18n.t("enums.area.#{key}", default: key.to_s.humanize)
    end
  end

  def sentiment_analysis
    comments = object.employee_feedbacks.pluck(:enps_aberta).compact
    results = { positive: 0, neutral: 0, negative: 0 }

    comments.each do |text|
      next if text == '-'
      sentiment = SENTIMENT_ANALYZER.sentiment(text)
      results[sentiment] += 1
    end
    results
  end

  def sentiment_details
    comments = object.employee_feedbacks.where.not(enps_aberta: [nil, '-', '']).pluck(:enps_aberta)
    
    negative_comments = comments.select { |c| SENTIMENT_ANALYZER.sentiment(c) == :negative }
    
    stop_words = %w[a o que e do da de um uma em para com no na por os as]
    words = negative_comments.join(" ").downcase.scan(/\w+/)
    top_words = words.reject { |w| stop_words.include?(w) || w.size < 4 }
                     .group_by(&:itself)
                     .transform_values(&:count)
                     .sort_by { |_k, v| -v }.first(5).to_h

    {
      top_negative_terms: top_words,
      critical_quotes: negative_comments.sample(3)
    }
  end

  def eda
    scores = object.employee_feedbacks.pluck(:feedback).compact
    return {} if scores.empty?

    {
      mean: (scores.sum.to_f / scores.size).round(2),
      median: calculate_median(scores),
      mode: scores.group_by { |v| v }.max_by { |_, v| v.size }&.first
    }
  end

  def ai_insights
    low_area = object.employee_feedbacks.group(:area).average(:feedback).min_by { |_, v| v }
    return nil unless low_area

    translated_area = I18n.t("enums.area.#{low_area[0]}", default: low_area[0].to_s.humanize)
    
    {
      critical_area: translated_area,
      recommendation: low_area[1] < 3.5 ? 
        "Prioridade Crítica: #{translated_area} exige revisão imediata de processos e carga de trabalho." : 
        "Foco em Engajamento: #{translated_area} possui a menor média; sugere-se mentorias com lideranças."
    }
  end

  def feedbacks
    ActiveModel::Serializer::CollectionSerializer.new(
      object.employee_feedbacks,
      serializer: EmployeeFeedbackSerializer
    )
  end

  def ai_insights
    area_averages = object.employee_feedbacks.group(:area).average(:feedback)
    return nil if area_averages.empty?

    worst_area_raw, worst_score = area_averages.min_by { |_, v| v }
    best_area_raw, best_score = area_averages.max_by { |_, v| v }

    worst_area = I18n.t("enums.area.#{worst_area_raw}", default: worst_area_raw.to_s.humanize)
    best_area = I18n.t("enums.area.#{best_area_raw}", default: best_area_raw.to_s.humanize)

    worst_comments = object.employee_feedbacks.where(area: worst_area_raw).pluck(:enps_aberta).compact
    results = { positive: 0, neutral: 0, negative: 0 }
    worst_comments.each { |t| results[SENTIMENT_ANALYZER.sentiment(t)] += 1 if t != '-' }
    predominant_sentiment = results.max_by { |_, v| v }&.first

    {
      critical_area: worst_area,
      score: worst_score.to_f.round(2),
      recommendation: dynamic_recommendation(worst_area, worst_score, predominant_sentiment, best_area)
    }
  end

  private

  def dynamic_recommendation(area, score, sentiment, benchmark_area)
    if score < 3.0
      "Alerta Crítico: #{area} está com média #{score}. O sentimento predominante é #{sentiment}. Recomenda-se intervenção imediata do RH e revisão do modelo de gestão comparando com #{benchmark_area}."
    elsif sentiment == :negative
      "Risco de Turnover: Apesar da média #{score}, os comentários em #{area} são majoritariamente negativos. Focar em escuta ativa e revisão de benefícios/clima."
    elsif score < 4.0
      "Plano de Desenvolvimento: #{area} apresenta estabilidade, mas está abaixo do benchmark (#{benchmark_area}). Sugere-se treinamentos técnicos e maior clareza na trilha de carreira."
    else
      "Manutenção de Performance: #{area} performa bem, mas é a menor do grupo. Manter rotina de 1:1s e reconhecimentos públicos para evitar estagnação."
    end
  end

  def calculate_enps(scope)
    p = scope.where(enps: 9..10).count
    d = scope.where(enps: 0..6).count
    ((p - d).to_f / scope.count * 100).round(2)
  end

  def calculate_favorability(scope)
    favorable = scope.where(feedback: 4..5).count
    ((favorable.to_f / scope.count) * 100).round(2)
  end

  def calculate_median(array)
    sorted = array.sort
    len = sorted.length
    ((sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0).round(2)
  end
end