require 'rails_helper'

RSpec.describe Api::V1::FeedbacksController, type: :controller do
  let(:import_file) { create(:import_file) }
  let!(:feedback) { create(:employee_feedback, import_file: import_file) }

  describe "GET #index" do
    it "lista os feedbacks com paginação" do
      get :index
      
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['meta']).to have_key('total_pages')
    end
  end
end