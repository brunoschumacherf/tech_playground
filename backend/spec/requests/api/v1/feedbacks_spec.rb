require 'rails_helper'

RSpec.describe Api::V1::FeedbacksController, type: :controller do
  let(:import_file) { create(:import_file) }
  let(:import_file2) { create(:import_file) }
  let!(:feedback) { create(:employee_feedback, import_file: import_file) }
  let!(:feedback2) { create(:employee_feedback, import_file: import_file2) }
  let!(:feedback3) { create(:employee_feedback, import_file: import_file) }

  describe "GET #index" do
    before do
      EmployeeFeedback.delete_all
      ImportFile.delete_all
    end
    context 'when fetching all feedbacks' do
      before do
        import_file = create(:import_file)
        import_file2 = create(:import_file)
        create(:employee_feedback, import_file: import_file)
        create(:employee_feedback, import_file: import_file2)
        create(:employee_feedback, import_file: import_file)
      end

      it 'lista os feedbacks com paginação' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_an(Array)
        expect(json_response['meta']).to have_key('total_pages')
      end

      it 'returns all feedbacks ordered by created_at desc' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end

      it 'includes import_file association' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first).to have_key('import_file_id')
      end

      it 'returns pagination metadata' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['meta']).to include(
          'total_count',
          'total_pages',
          'current_page',
          'per_page'
        )
        expect(json_response['meta']['per_page']).to eq(20)
      end
    end

    context 'when filtering by import_id' do
      let(:test_import_file) { create(:import_file) }
      let(:test_import_file2) { create(:import_file) }
      
      before do
        create(:employee_feedback, import_file: test_import_file)
        create(:employee_feedback, import_file: test_import_file)
        create(:employee_feedback, import_file: test_import_file2)
      end

      it 'returns only feedbacks for the specified import' do
        get :index, params: { import_id: test_import_file.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
        json_response['data'].each do |feedback_data|
          expect(feedback_data['import_file_id']).to eq(test_import_file.id)
        end
      end

      it 'returns empty array when import_id has no feedbacks' do
        empty_import = create(:import_file)
        get :index, params: { import_id: empty_import.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_empty
      end

      it 'returns all feedbacks when import_id is blank' do
        get :index, params: { import_id: '' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end
    end

    context 'when using pagination' do
      let(:test_import_file) { create(:import_file) }
      
      before do
        EmployeeFeedback.delete_all
        25.times { create(:employee_feedback, import_file: test_import_file) }
      end

      it 'paginates results with default page size' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(20)
        expect(json_response['meta']['per_page']).to eq(20)
      end

      it 'returns correct page when page parameter is provided' do
        get :index, params: { page: 2 }
        
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['current_page']).to eq(2)
      end

      it 'returns correct total_pages' do
        get :index
        
        json_response = JSON.parse(response.body)
        total_items = 25
        expected_pages = (total_items.to_f / 20).ceil
        expect(json_response['meta']['total_pages']).to eq(expected_pages)
      end

      it 'returns correct total_count' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['total_count']).to eq(25)
      end
    end

    context 'when there are no feedbacks' do
      before do
        EmployeeFeedback.delete_all
      end

      it 'returns empty array' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_empty
        expect(json_response['meta']['total_count']).to eq(0)
      end
    end
  end
end