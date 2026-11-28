Rails.application.routes.draw do
  resource :session
  patch "locale/:locale" => "locales#update", as: :locale
  resources :passwords, param: :token

  # Öffentlich: Events und Ergebnisse
  resources :events, only: %i[index show]

  # Einladungen (öffentlich, per Token)
  resources :invitations, param: :token, only: %i[show update]

  # Fahrerlager (Fahrer): Start und Profil
  resource :hub, controller: "hub", only: %i[show edit update] do
    get :profile
  end

  # App-Bereich für Fahrer und Organisatoren: Infos & Fragen, Chat
  get "info" => "info#show", as: :info
  resources :chat_rooms, path: "chat", only: %i[index show] do
    patch :read, on: :member
    resources :messages, controller: "chat_messages", only: %i[create destroy]
  end

  # Besucher und Helfer
  resource :guest, controller: "guest", only: :show, path: "gast"

  # Staff
  namespace :admin do
    resources :chat_rooms, except: :show
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

  # Installierbare App (PWA)
  get "launch" => "home#launch", as: :launch
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "pages#home"

  # Redaktionelle Seiten: /training, /preise, ... (nur für vorhandene, veröffentlichte Seiten)
  get ":slug", to: "content_pages#show", as: :content_page,
      constraints: ->(request) { Page.published.exists?(slug: request.path_parameters[:slug]) }

  # Alles Übrige: Adressen der alten Webseite weiterleiten, sonst "Umbau"-Seite (404).
  # Muss die letzte Route bleiben.
  get "*path" => "fallback#show",
      constraints: ->(request) { request.format.html? && !request.path.start_with?("/rails/", "/cable", "/assets/") }
end
