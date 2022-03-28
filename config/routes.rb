Rails.application.routes.draw do
  root "home#index"

  devise_for :users, controllers: { registrations: "registrations" }
  resources :extra_registrations, only: [:index, :edit, :update]
  resource :user, only: [:show, :edit, :update], controller: :user do
    get "check_email"
  end

  resources :modules, only: [:index], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: [:index, :show]
    resources :questionnaires, only: [:show, :update]
  end

  resources :static, only: :show
end
