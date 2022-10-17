Rails.application.routes.draw do
  root 'home#index'
  get 'health', to: 'home#show'
  get 'my-modules', to: 'learning#show'
  get 'about-training', to: 'training_modules#index', as: :course_overview

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all
  get 'users/timeout', to: 'errors#timeout'

  resources :settings, controller: :settings, only: %i[show create]

  devise_for :users, controllers: { sessions: 'users/sessions', confirmations: 'confirmations', passwords: 'passwords', registrations: 'registrations' }, path_names: { sign_in: 'sign-in', sign_out: 'sign-out', sign_up: 'sign-up' }
  resources :extra_registrations, only: %i[index edit update], path: 'extra-registrations'

  resource :user, controller: :user, path: 'my-account', only: %i[show] do
    get 'edit-name'
    get 'edit-email'
    get 'edit-ofsted-number'
    get 'edit-password'
    get 'edit-postcode'
    get 'edit-setting-type'
    patch 'update-name'
    patch 'update-email'
    patch 'update-ofsted-number'
    patch 'update-password'
    patch 'update-postcode'
    patch 'update-setting-type'
    get 'check-email-confirmation'
    get 'check-email-password-reset'
    resource :notes, path: 'learning-log', only: %i[show create update]
  end

  resources :modules, only: %i[show], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: %i[index show], path: 'content-pages'
    resources :questionnaires, only: %i[show update]
    resources :assessment_results, only: %i[show new], path: 'assessment-result'
  end

  get '/:id', to: 'static#show', as: :static
end
