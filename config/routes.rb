BSides::Application.routes.draw do
  root :to => 'home#index'

  resources :users
  resources :user_sessions
  resources :artists, as: "artists" do
    resources :assets, as: "assets"
    get   'pay' => "assets#pay",      :as => 'pay' 
    post  'pay' => "assets#postPay",  :as => 'pay_post' 
  end

  match 'login' => 'user_sessions#new', :as => :login, :via => :get
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :get

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Github
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
end
