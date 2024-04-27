# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "landing#landing"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :accounts_and_goals do
    get "/", to: "landing#landing"

    resources :summary, only: [] do
      collection do
        get :capital
        get :debt
        get :total
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
