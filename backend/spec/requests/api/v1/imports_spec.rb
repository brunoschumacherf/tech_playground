require 'rails_helper'

RSpec.describe Api::V1::ImportsController, type: :controller do
  describe "GET #index" do
    it "retorna sucesso" do
      get :index, params: { page: 1 }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let!(:import_file) { ImportFile.create!(name: "test.csv") }

    it "retorna sucesso para dataset existente" do
      get :show, params: { id: import_file.id }
      expect(response).to have_http_status(:success)
    end

    it "retorna 404 para dataset inexistente" do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body)
      expect(json["error"]).to eq(I18n.t('imports.errors.not_found'))
    end
  end

  describe "POST #create" do
    let(:file_path) { Rails.root.join('spec/fixtures/data.csv') }
    let(:file) { fixture_file_upload(file_path, 'text/csv') }

    before do
      FileUtils.mkdir_p(Rails.root.join('spec/fixtures'))
      File.write(file_path, "nome,email,enps\nBruno,bruno@test.com,10") unless File.exist?(file_path)
    end

    it "cria um novo import" do
      post :create, params: { file: file }
      expect(response).to have_http_status(:accepted)
    end

    it "retorna erro se o arquivo estiver ausente" do
      post :create, params: { file: nil }
      expect(response).to have_http_status(:bad_request)
    end
  end
end