Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Einladungen (öffentlich, per Token)
  resources :invitations, param: :token, only: %i[show update]

  # Rider Hub (Fahrer)
  resource :hub, controller: "hub", only: %i[show edit update]

  # Staff
  namespace :admin do
    resources :riders, only: %i[index show new create] do
      post :invite, on: :member
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
