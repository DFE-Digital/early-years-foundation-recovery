Rails.application.routes.draw do
  root 'home#index'

  get '/404', to: 'errors#not_found', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all
  get 'users/timeout', to: 'errors#timeout'
  get 'health', to: 'home#show'

  devise_for :users, controllers: { sessions: 'users/sessions' }
  resources :extra_registrations, only: %i[index edit update]
  resource :user, only: %i[show edit update], controller: :user do
    get 'check_email'
  end

  resources :modules, only: [:index], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: %i[index show]
    resources :questionnaires, only: %i[show update]
  end

  resources :static, only: :show
end
