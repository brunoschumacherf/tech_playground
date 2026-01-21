require 'rails_helper'

RSpec.describe Api::V1::ImportsController, type: :controller do
  let!(:import_file) { ImportFile.create!(name: "pesquisa_clima.csv") }
  
  let!(:feedback) do
    EmployeeFeedback.create!(
      import_file: import_file,
      nome: "Bruno Developer",
      email: "bruno@example.com",
      area: "Tecnologia",
      enps: 10,
      feedback: 5
    )
  end

  let(:csv_fixture) { fixture_file_upload('spec/fixtures/files/sample.csv', 'text/csv') }

  describe "GET #index" do
    it "retorna a lista de imports com feedbacks_count" do
      get :index
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
      expect(json['data'].first).to have_key('feedbacks_count')
    end
  end

  describe "GET #show" do
    it "retorna o dashboard consolidado do arquivo específico" do
      get :show, params: { id: import_file.id }
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      
      expect(json).to have_key("info")
      expect(json["info"]["id"]).to eq(import_file.id)
      expect(json).to have_key("summary")
      expect(json["summary"]["total_responses"]).to be >= 1
      expect(json).to have_key("by_area")
      expect(json).to have_key("sentiment_analysis")
    end

    it "retorna 404 para um ID inexistente" do
      get :show, params: { id: 9999 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq(I18n.t('imports.errors.not_found'))
    end
  end

  describe "POST #create" do
    context "com arquivo CSV válido" do
      it "cria o registro e processa os dados (Sem Mock)" do
        expect {
          post :create, params: { file: csv_fixture }
        }.to change(ImportFile, :count).by(1)
        
        expect(response).to have_http_status(:accepted)
        
        json = JSON.parse(response.body)
        expect(json).to have_key("import_id")
        expect(json["message"]).to eq(I18n.t('imports.messages.processing_started'))
      end
    end

    context "sem enviar arquivo" do
      it "retorna erro 400 bad request" do
        post :create, params: { file: nil }
        expect(response).to have_http_status(:bad_request)
        
        json = JSON.parse(response.body)
        expect(json["error"]).to eq(I18n.t('imports.errors.no_file'))
      end
    end
  end
end