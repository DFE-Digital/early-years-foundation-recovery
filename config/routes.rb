Rails.application.routes.draw do
  root "home#index"

  resources :training_modules, only: [:index]
end
