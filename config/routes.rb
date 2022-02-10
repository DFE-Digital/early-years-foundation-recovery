Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: { registrations: "registrations" }
  resources :modules, only: [:index], as: :training_modules, controller: :training_modules do
    resources :topics, only: [:index, :show] do
      collection do
        get :recap
      end
    end
  end
  resources :extra_registrations, only: [:index, :edit, :update]
end
