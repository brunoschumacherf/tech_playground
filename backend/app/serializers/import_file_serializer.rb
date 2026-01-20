class ImportFileSerializer < ActiveModel::Serializer
  attributes :info, :summary, :by_area, :sentiment_analysis, :feedbacks, :eda, :ai_insights

  def info
    {
      id: object.id,
      name: object.name,
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

  private

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