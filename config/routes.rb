Rails.application.routes.draw do
  root 'home#index'

  get '/404', to: 'errors#not_found', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all
  get 'users/timeout', to: 'errors#timeout'
  get 'health', to: 'home#show'

  resources :settings, only: %i[show]

  devise_for :users, controllers: { sessions: 'users/sessions', passwords: 'passwords', registrations: 'registrations' }
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

  resources :modules, only: [:index], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: %i[index show]
    resources :questionnaires, only: %i[show update]
    resources :formative_assessments, only: %i[show update]
  end

  %w[accessibility-statement privacy-policy terms-and-conditions].each do |static_page|
    get "/#{static_page}", to: "static##{static_page}"
  end

end
