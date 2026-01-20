class Api::V1::FeedbacksController < ApplicationController
  def index
    total = EmployeeFeedback.count
    promoters = EmployeeFeedback.where(enps: 9..10).count
    detractors = EmployeeFeedback.where(enps: 0..6).count
    
    enps_score = total.positive? ? (((promoters - detractors).to_f / total) * 100).round(2) : 0

    render json: {
      summary: {
        total_responses: total,
        enps_score: enps_score,
        promoters_count: promoters,
        detractors_count: detractors
      },
      by_area: EmployeeFeedback.group(:area).average(:feedback),
      recent_feedbacks: EmployeeFeedback.last(10)
    }
  end
end