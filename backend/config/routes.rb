Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'dashboard', to: 'feedbacks#index'
    end
  end
end