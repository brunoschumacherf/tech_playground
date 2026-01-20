class Api::V1::FeedbacksController < ApplicationController
  def index
    total_count = EmployeeFeedback.count
    return render json: { summary: {}, by_area: {}, alerts: {} } if total_count.zero?

    favorable = EmployeeFeedback.where(feedback: 4..5).count
    favorability_rate = ((favorable.to_f / total_count) * 100).round(2)

    areas = EmployeeFeedback.distinct.pluck(:area)
    alerts = {}

    areas.each do |area_name|
      area_scope = EmployeeFeedback.where(area: area_name)
      area_total = area_scope.count
      next if area_total.zero?

      p = area_scope.where(enps: 9..10).count
      d = area_scope.where(enps: 0..6).count
      
      score = ((p - d).to_f / area_total * 100).round(2)
      alerts[area_name] = score if score < 0
    end

    render json: {
      summary: {
        total_responses: total_count,
        enps_score: calculate_enps_global(total_count),
        favorability: favorability_rate,
        promoters_count: EmployeeFeedback.where(enps: 9..10).count,
        detractors_count: EmployeeFeedback.where(enps: 0..6).count
      },
      by_area: EmployeeFeedback.group(:area).average(:feedback),
      alerts: alerts
    }
  end

  private

  def calculate_enps_global(total)
    p = EmployeeFeedback.where(enps: 9..10).count
    d = EmployeeFeedback.where(enps: 0..6).count
    ((p - d).to_f / total * 100).round(2)
  end
end