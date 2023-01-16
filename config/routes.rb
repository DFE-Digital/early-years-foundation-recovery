Rails.application.routes.draw do
  root 'home#index'
  get 'health', to: 'home#show'
  get 'my-modules', to: 'learning#show'
  get 'about-training', to: 'training_modules#index', as: :course_overview

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  resources :settings, controller: :settings, only: %i[show create]

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               confirmations: 'confirmations',
               passwords: 'passwords',
               registrations: 'registrations',
             },
             path_names: {
               sign_in: 'sign-in',
               sign_out: 'sign-out',
               sign_up: 'sign-up',
             }

  # @see TimeoutWarning js component
  # @note these path names are required
  devise_scope :user do
    get 'check_session_timeout', to: 'timeout#check'
    get 'extend_session', to: 'timeout#extend'
    get 'users/timeout', to: 'timeout#timeout_user'
  end

  namespace :registration do
    resource :name, only: %i[edit update]
    resource :setting_type, only: %i[edit update], path: 'setting-type'
    resource :setting_type_other, only: %i[edit update], path: 'setting-type-other'
    resource :local_authority, only: %i[edit update], path: 'local-authority'
    resource :role_type, only: %i[edit update], path: 'role-type'
    resource :role_type_other, only: %i[edit update], path: 'role-type-other'
  end

  resource :user, controller: :user, path: 'my-account', only: %i[show] do
    get 'edit-email'
    get 'edit-password'
    patch 'update-email'
    patch 'update-password'
    get 'check-email-confirmation'
    get 'check-email-password-reset'
    resource :notes, path: 'learning-log', only: %i[show create update]
    resource :close_account, path: 'close', only: %i[new update show] do
      get 'reset-password'
      get 'edit-reason'
      patch 'update-reason'
      get 'confirm-close-account'
      post 'delete_account'
    end
  end

  resources :modules, only: %i[show], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: %i[index show], path: 'content-pages'
    resources :questionnaires, only: %i[show update]
    resources :assessment_results, only: %i[show new], path: 'assessment-result'
  end

  get '/:id', to: 'static#show', as: :static
end
