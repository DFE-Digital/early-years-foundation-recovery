Rails.application.routes.draw do
  root 'home#index'
  get 'health', to: 'home#show'
  get 'audit', to: 'home#audit'

  get 'my-modules', to: 'learning#show' # @see User#course
  get 'about-training', to: 'training/modules#index', as: :course_overview
  get 'gov-one/info', to: 'gov_one#show'

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
               omniauth_callbacks: 'users/omniauth_callbacks',
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
    get '/users/sign_out', to: 'users/sessions#destroy'
  end

  namespace :registration do
    resource :name, only: %i[edit update]
    resource :setting_type, only: %i[edit update], path: 'setting-type'
    resource :setting_type_other, only: %i[edit update], path: 'setting-type-other'
    resource :local_authority, only: %i[edit update], path: 'local-authority'
    resource :role_type, only: %i[edit update], path: 'role-type'
    resource :role_type_other, only: %i[edit update], path: 'role-type-other'
    resource :training_emails, only: %i[edit update], path: 'training-emails'
    resource :early_years_emails, only: %i[edit update], path: 'early-years-emails'
  end

  resource :user, controller: :user, only: %i[show], path: 'my-account' do
    get 'edit-email'
    get 'edit-password'
    patch 'update-email'
    patch 'update-password'
    get 'check-email-confirmation'
    get 'check-email-password-reset'
    get 'edit-training-emails'
    devise_for :users, controllers: { omniauth_callbacks: 'controllers/users/omniauth_callbacks' }
    patch 'update-training-emails'

    resource :close_account, only: %i[new update show], path: 'close' do
      get 'reset-password'
      get 'edit-reason'
      patch 'update-reason'
      get 'confirm'
      post 'close_account'
    end

    scope module: 'training' do
      resource :notes, path: 'learning-log', only: %i[show create update]
    end
  end

  constraints proc { Rails.application.preview? || Rails.env.test? } do
    resources :snippets, id: /[^\/]+/, only: %i[show]
  end

  scope module: 'training' do
    resources :modules, only: %i[show], as: :training_modules do
      constraints proc { Rails.application.preview? || Rails.application.debug? } do
        get '/structure', to: 'debug#show'
      end

      resources :pages, only: %i[index show], path: 'content-pages'
      resources :questions, only: %i[show], path: 'questionnaires'
      resources :responses, only: %i[update]
      resources :assessments, only: %i[show new], path: 'assessment-result'
    end
  end

  post '/change', to: 'hook#change'
  post '/release', to: 'hook#release'

  resources :pages, only: %i[show], path: '/', as: :static
end
