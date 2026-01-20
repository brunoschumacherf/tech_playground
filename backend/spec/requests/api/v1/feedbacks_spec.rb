require 'rails_helper'

RSpec.describe "Api::V1::Feedbacks", type: :request do
  describe "GET /api/v1/dashboard" do
    let(:headers) { { "ACCEPT" => "application/json" } }

    before do
      EmployeeFeedback.delete_all
      
      create_list(:employee_feedback, 5, enps: 10)
      create_list(:employee_feedback, 5, enps: 0) 
      
      get "/api/v1/dashboard", headers: headers
    end

    it "retorna status HTTP 200" do
      expect(response).to have_http_status(:ok)
    end

    it "retorna o conteúdo em formato JSON" do
      expect(response.content_type).to match(a_string_including("application/json"))
    end

    it "retorna o cálculo de eNPS correto" do
      json = JSON.parse(response.body)
      expect(json["summary"]["enps_score"].to_f).to eq(0.0)
    end
  end
end