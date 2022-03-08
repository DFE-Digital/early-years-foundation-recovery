Rails.application.routes.draw do
  root "home#index"

  devise_for :users, controllers: { registrations: "registrations" }
  resources :extra_registrations, only: [:index, :edit, :update]

  resources :modules, only: [:index], as: :training_modules, controller: :training_modules do
    resources :content_pages, only: [:index, :show]
    resources :questionnaires, only: [:show, :update]
  end
end
