require 'rails_helper'

RSpec.describe Api::V1::ImportsController, type: :controller do
  let(:csv_fixture) { fixture_file_upload('spec/fixtures/files/sample.csv', 'text/csv') }

  describe "GET #index" do
    before do
      EmployeeFeedback.delete_all
      ImportFile.delete_all
    end

    context 'when fetching all imports' do
      before do
        @import_file = create(:import_file, name: "pesquisa_clima.csv")
        create(:employee_feedback, import_file: @import_file)
      end
      it 'retorna a lista de imports com feedbacks_count' do
        get :index
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json['data']).to be_an(Array)
        expect(json['data'].first).to have_key('feedbacks_count')
      end

      it 'returns imports ordered by created_at desc' do
        EmployeeFeedback.delete_all
        ImportFile.delete_all
        older_import = ImportFile.create!(name: 'old.csv', created_at: 2.days.ago)
        newer_import = ImportFile.create!(name: 'new.csv', created_at: 1.day.ago)

        get :index
        
        json = JSON.parse(response.body)
        import_names = json['data'].map { |item| item['name'] }
        expect(import_names.first).to eq(newer_import.name)
      end

      it 'includes pagination metadata' do
        get :index
        
        json = JSON.parse(response.body)
        expect(json['meta']).to include(
          'current_page',
          'next_page',
          'prev_page',
          'total_pages',
          'total_count'
        )
      end

      it 'has default page size of 10' do
        get :index
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to be <= 10
      end
    end

    context 'when filtering by query parameter' do
      before do
        ImportFile.delete_all
        create(:import_file, name: 'research_climate.csv')
        create(:import_file, name: 'engagement_survey.csv')
        create(:import_file, name: 'other_file.csv')
      end

      it 'filters imports by name when query is provided' do
        get :index, params: { query: 'research' }
        
        json = JSON.parse(response.body)
        expect(json['data'].all? { |item| item['name'].downcase.include?('research') }).to be true
      end

      it 'returns case insensitive search results' do
        get :index, params: { query: 'CLIMATE' }
        
        json = JSON.parse(response.body)
        expect(json['data'].any? { |item| item['name'].downcase.include?('climate') }).to be true
      end

      it 'returns empty array when query matches nothing' do
        get :index, params: { query: 'nonexistent123456' }
        
        json = JSON.parse(response.body)
        expect(json['data']).to be_empty
      end

      it 'returns all imports when query is blank' do
        get :index, params: { query: '' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to be > 0
      end
    end

    context 'when using pagination' do
      before do
        ImportFile.delete_all
        15.times { create(:import_file) }
      end

      it 'paginates results with page size 10' do
        get :index
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(10)
      end

      it 'returns second page when page parameter is 2' do
        get :index, params: { page: 2 }
        
        json = JSON.parse(response.body)
        expect(json['meta']['current_page']).to eq(2)
        expect(json['data'].length).to be <= 10
      end

      it 'returns correct total_count' do
        get :index
        
        json = JSON.parse(response.body)
        expect(json['meta']['total_count']).to eq(15)
      end
    end

    context 'when there are no imports' do
      before do
        ImportFile.delete_all
      end

      it 'returns empty array' do
        get :index
        
        json = JSON.parse(response.body)
        expect(json['data']).to be_empty
        expect(json['meta']['total_count']).to eq(0)
      end
    end
  end

  describe "GET #show" do
    context 'when import file exists' do
      let(:test_import_file) do
        file = create(:import_file, name: "pesquisa_clima.csv")
        create(:employee_feedback,
          import_file: file,
          nome: "Bruno Developer",
          email: "bruno@example.com",
          area: "Tecnologia",
          enps: 10,
          feedback: 5
        )
        file
      end

      it "retorna o dashboard consolidado do arquivo específico" do
        get :show, params: { id: test_import_file.id }
        
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        
        expect(json).to have_key("info")
        expect(json["info"]["id"]).to eq(test_import_file.id)
        expect(json).to have_key("summary")
        expect(json["summary"]["total_responses"]).to be >= 1
        expect(json).to have_key("by_area")
        expect(json).to have_key("sentiment_analysis")
      end

      it 'includes all required serializer attributes' do
        get :show, params: { id: test_import_file.id }
        
        json = JSON.parse(response.body)
        
        expect(json['info']).to include('id', 'name', 'status', 'created_at')
        expect(json['summary']).to include('total_responses', 'enps_score', 'favorability')
      end

      it 'returns import file with correct id' do
        get :show, params: { id: test_import_file.id }
        
        json = JSON.parse(response.body)
        expect(json['info']['id']).to eq(test_import_file.id)
        expect(json['info']['name']).to eq(test_import_file.name)
      end
    end

    context 'when import file does not exist' do
      it "retorna 404 para um ID inexistente" do
        get :show, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq(I18n.t('imports.errors.not_found'))
      end

      it 'returns error message in correct format' do
        get :show, params: { id: 999999 }
        
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
        expect(json['error']).to be_a(String)
      end
    end

    context 'when import file has no feedbacks' do
      let(:empty_import) { create(:import_file) }

      it 'returns summary with zero responses' do
        get :show, params: { id: empty_import.id }
        
        json = JSON.parse(response.body)
        expect(json['summary']).to eq({})
      end
    end
  end

  describe "POST #create" do
    before do
      clear_enqueued_jobs
    end

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

      it 'creates import file with processing status' do
        post :create, params: { file: csv_fixture }
        
        json = JSON.parse(response.body)
        import = ImportFile.find(json['import_id'])
        expect(import.status).to eq('processing')
      end

      it 'sets the correct filename' do
        post :create, params: { file: csv_fixture }
        
        json = JSON.parse(response.body)
        import = ImportFile.find(json['import_id'])
        expect(import.name).to eq('sample.csv')
      end

      it 'enqueues ImportCsvJob' do
        expect {
          post :create, params: { file: csv_fixture }
        }.to have_enqueued_job(ImportCsvJob)
      end
    end

    context "sem enviar arquivo" do
      it "retorna erro 400 bad request" do
        post :create, params: { file: nil }
        expect(response).to have_http_status(:bad_request)
        
        json = JSON.parse(response.body)
        expect(json["error"]).to eq(I18n.t('imports.errors.no_file'))
      end

      it 'does not create import file when file is missing' do
        expect {
          post :create, params: { file: nil }
        }.not_to change(ImportFile, :count)
      end

      it 'does not enqueue job when file is missing' do
        expect {
          post :create, params: { file: nil }
        }.not_to have_enqueued_job(ImportCsvJob)
      end
    end

    context 'when import file validation fails' do
      it 'returns error when filename is not CSV' do
        non_csv_file = fixture_file_upload('spec/fixtures/files/sample.csv', 'text/csv')
        allow(non_csv_file).to receive(:original_filename).and_return('test.pdf')

        post :create, params: { file: non_csv_file }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end
  end
end