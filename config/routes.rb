Rails.application.routes.draw do
  root 'home#index'
  get 'health', to: 'home#show'
  get 'my-learning', to: 'learning#show'

  get '/404', to: 'errors#not_found', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all
  get 'users/timeout', to: 'errors#timeout'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'passwords',
    registrations: 'registrations',
  }

  resources :settings, only: %i[show]
  resources :static, only: %i[show]
  resources :extra_registrations, only: %i[index edit update]

  resource :user, controller: :user, path: 'my-account', only: %i[show] do
    get 'edit-name'
    get 'edit-email'
    get 'edit-ofsted-number'
    get 'edit-password'
    get 'edit-postcode'
    patch 'update-name'
    patch 'update-email'
    patch 'update-ofsted-number'
    patch 'update-password'
    patch 'update-postcode'
    get 'check_email_confirmation'
    get 'check_email_password_reset'
  end

  resources :modules, only: %i[index show], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: %i[index show]
    resources :questionnaires, only: %i[show update]
    resources :formative_assessments, only: %i[show update]
    resources :summetive_assessments, only: %i[show update] do
      get 'results'
    end
  end
end
