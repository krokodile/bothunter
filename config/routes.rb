Telefront::Application.routes.draw do

  resources :profiles

  resources :groups

  resources :campaigns

  resources :pages

  devise_for :users
  
  root :to => "pages#index"

end
