Telefront::Application.routes.draw do

  resources :campaigns

  resources :pages

  devise_for :users
  
  root :to => "pages#index"

end
