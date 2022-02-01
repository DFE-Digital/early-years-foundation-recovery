Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: { registrations: "registrations" }
  resources :training_modules, only: [:index]
  resources :extra_registrations, only: [:index, :edit, :update]
end
