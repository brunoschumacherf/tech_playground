require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      page = params[:page]&.to_i || 1
      collection = ImportFile.page(page).per(10)
      render json: { meta: pagination_meta(collection) }
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
    end
  end

  describe '#pagination_meta' do
    before do
      EmployeeFeedback.delete_all
      ImportFile.delete_all
      create_list(:import_file, 25)
    end

    it 'returns pagination metadata hash' do
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

    it 'returns correct current_page' do
      get :index

      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(1)
    end

    it 'returns correct total_count' do
      get :index

      json = JSON.parse(response.body)
      expect(json['meta']['total_count']).to eq(25)
    end

    it 'returns correct total_pages' do
      get :index

      json = JSON.parse(response.body)
      expect(json['meta']['total_pages']).to eq(3)
    end

    it 'returns next_page when there are more pages' do
      get :index

      json = JSON.parse(response.body)
      expect(json['meta']['next_page']).to eq(2)
    end

    it 'returns nil for next_page on last page' do
      get :index, params: { page: 3 }

      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(3)
      expect(json['meta']['next_page']).to be_nil
    end

    it 'returns nil for prev_page on first page' do
      get :index

      json = JSON.parse(response.body)
      expect(json['meta']['prev_page']).to be_nil
    end

    it 'returns correct prev_page when not on first page' do
      get :index, params: { page: 2 }

      json = JSON.parse(response.body)
      expect(json['meta']['prev_page']).to eq(1)
    end

    context 'when collection is empty' do
      before do
        ImportFile.delete_all
      end

      it 'returns zero for total_count' do
        get :index

        json = JSON.parse(response.body)
        expect(json['meta']['total_count']).to eq(0)
      end

      it 'returns zero for total_pages' do
        get :index

        json = JSON.parse(response.body)
        expect(json['meta']['total_pages']).to eq(0)
      end
    end
  end
end
