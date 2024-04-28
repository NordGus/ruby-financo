# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "landing#landing"

  namespace :accounts_and_goals do
    get "/", to: "summary#applet"
    get "summary/capital", to: "summary#capital", as: :capital_summary
    get "summary/debt", to: "summary#debt", as: :debt_summary
    get "summary/total", to: "summary#total", as: :total_summary
  end
end
