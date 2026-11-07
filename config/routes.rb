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
    resources :events do
      resources :categories, only: %i[create destroy]
      resources :registrations, only: %i[create update destroy] do
        patch :check_in, on: :member
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "start" => "home#index", as: :start
  root "pages#home"
end
