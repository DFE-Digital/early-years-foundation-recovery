Rails.application.routes.draw do
  root 'home#index'
  get 'health',     to: 'home#show'
  get 'audit',      to: 'home#audit'
  get 'my-modules', to: 'learning#show' # @see User#course

  get '404', to: 'errors#not_found', via: :all
  get '500', to: 'errors#internal_server_error', via: :all
  get '503', to: 'errors#service_unavailable', via: :all

  resources :settings, controller: :settings, only: %i[show create]

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               omniauth_callbacks: 'users/omniauth_callbacks',
             },
             path_names: {
               sign_in: 'sign-in',
             }

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy' # post_logout_redirect_uri
    get 'users/review',   to: 'users/sessions#sign_in_test_user' unless Rails.application.live?
  end

  namespace :registration do
    resource :terms_and_conditions,   only: %i[edit update], path: 'terms-and-conditions'
    resource :name,                   only: %i[edit update]
    resource :setting_type,           only: %i[edit update], path: 'setting-type'
    resource :setting_type_other,     only: %i[edit update], path: 'setting-type-other'
    resource :local_authority,        only: %i[edit update], path: 'local-authority'
    resource :role_type,              only: %i[edit update], path: 'role-type'
    resource :role_type_other,        only: %i[edit update], path: 'role-type-other'
    resource :early_years_experience, only: %i[edit update], path: 'early-years-experience'
    resource :training_emails,        only: %i[edit update], path: 'training-emails'
  end

  resource :user, controller: :user, only: %i[show], path: 'my-account' do
    resource :close_account, only: %i[update show], path: 'close' do
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
        get 'structure', to: 'debug#show'
      end

      resources :pages,       only: %i[index show], path: 'content-pages'
      resources :questions,   only: %i[show],       path: 'questionnaires'
      resources :assessments, only: %i[show],       path: 'assessment-result'
      resources :responses,   only: %i[update]
    end
  end

  resources :feedback, only: %i[index show update]

  post 'notify',  to: 'notify#update'
  post 'change',  to: 'release#update'
  post 'release', to: 'release#new'

  get 'about-training',    to: 'about#course',  as: :course_overview
  get 'about/the-experts', to: 'about#experts', as: :experts
  resources :about, only: %i[show], path: 'about'

  resources :pages, only: %i[show], path: '/', as: :static
end
