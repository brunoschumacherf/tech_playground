Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :imports, only: [:index, :show, :create]
      resources :feedbacks, only: [:index]
    end
  end

  root to: redirect('/api-docs')
end