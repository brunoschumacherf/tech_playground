require 'rails_helper'

RSpec.describe "Api::V1::Feedbacks", type: :request do
  describe "GET /api/v1/dashboard" do
    let(:headers) { { "ACCEPT" => "application/json" } }

    before do
      EmployeeFeedback.delete_all

      create_list(:employee_feedback, 3, area: "Vendas", enps: 0, feedback: 1)
      create_list(:employee_feedback, 3, area: "TI", enps: 10, feedback: 5)
      
      get "/api/v1/dashboard", headers: headers
    end

    it "retorna status 200" do
      expect(response).to have_http_status(:ok)
    end

    it "calcula a favorabilidade corretamente" do
      json = JSON.parse(response.body)
      expect(json["summary"]["favorability"].to_f).to eq(50.0)
    end

    it "gera alertas para áreas com eNPS negativo" do
      json = JSON.parse(response.body)
      expect(json["alerts"]).to have_key("Vendas")
      expect(json["alerts"]["Vendas"].to_f).to eq(-100.0)
    end
  end
end