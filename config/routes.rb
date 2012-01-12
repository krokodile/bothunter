BotHunter::Application.routes.draw do

  post "pages/create", as: 'add_group'

  resources :profiles

  resources :groups do
    member do
      post :delete_robots
    end
  end

  resources :campaigns

  resources :pages

  devise_for :users

  resources :users do
    resources :manual_invoices

    member do
      post 'manager'
    end
  end
  
  root :to => "pages#index"

end
