require "sidekiq/web"

Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [ :create ]
  resource :session, only: [ :create, :destroy ]
  get "/profile", to: "profiles#show"

  # Mount Admin engine at /admin
  mount Admin::Engine, at: "/admin"

  if Rails.env.development? || Rails.env.test?
    mount Sidekiq::Web => "/sidekiq"
  end
end
