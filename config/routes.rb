BSides::Application.routes.draw do
  root :to => 'home#index'

  resources :users do
    collection do
      get :login_from_http_basic
    end
    member do
      get :activate
    end
  end

  resources :user_sessions

  match 'login' => 'user_sessions#new', :as => :login, :via => :get
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :get

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Github
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
end
