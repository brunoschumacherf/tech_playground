class Api::V1::FeedbacksController < ApplicationController
  def index
    @feedbacks = EmployeeFeedback.includes(:import_file).order(created_at: :desc)
    @feedbacks = @feedbacks.where(import_file_id: params[:import_id]) if params[:import_id].present?
    
    @feedbacks = @feedbacks.page(params[:page]).per(20)

    render json: {
      data: @feedbacks,
      meta: {
        total_count: @feedbacks.total_count,
        total_pages: @feedbacks.total_pages,
        current_page: @feedbacks.current_page,
        per_page: 20
      }
    }
  end
end