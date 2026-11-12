Rails.application.routes.draw do
  resource :session
  patch "locale/:locale" => "locales#update", as: :locale
  resources :passwords, param: :token

  # Öffentlich: Events und Ergebnisse
  resources :events, only: %i[index show]

  # Einladungen (öffentlich, per Token)
  resources :invitations, param: :token, only: %i[show update]

  # Rider Hub (Fahrer)
  resource :hub, controller: "hub", only: %i[show edit update]

  # Besucher
  resource :guest, controller: "guest", only: :show, path: "gast"

  # Staff
  namespace :admin do
    resources :users, only: %i[index new create destroy]
    resources :riders, only: %i[index show new create] do
      post :invite, on: :member
    end
    resources :pages, except: :show
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

  # Redaktionelle Seiten: /training, /preise, ... (nur für vorhandene, veröffentlichte Seiten)
  get ":slug", to: "content_pages#show", as: :content_page,
      constraints: ->(request) { Page.published.exists?(slug: request.path_parameters[:slug]) }
end
