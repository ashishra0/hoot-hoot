Rails.application.routes.draw do
  root "pages#landing"

  # Auth
  get    "signup",  to: "registrations#new"
  post   "signup",  to: "registrations#create"
  get    "login",   to: "sessions#new"
  post   "login",   to: "sessions#create"
  delete "logout",  to: "sessions#destroy"

  # Dashboard
  get "dashboard", to: "dashboard#show"

  # Invites
  resources :invites, only: [ :create, :index ]
  get  "i/:token", to: "invites#show",  as: :invite
  post "i/:token", to: "invites#claim", as: :claim_invite

  # Friendships
  resources :friendships, only: [ :destroy ]

  # Hoots
  resources :hoots, only: [ :create ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
