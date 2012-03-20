BotHunter::Application.routes.draw do
  post "pages/create", as: 'add_group'

  resources :profiles

  resources :people, only: [] do
    member do
      get :humanize
      delete :humanize
    end
  end
  resources :groups do
    member do
      post :delete_robots
      get :report_persons
    end
  end

  resources :campaigns

  resources :pages

  devise_for :users

  resources :users do
    resources :manual_invoices

    collection do
      post :create_as_admin
      post :send_message_to_all
    end

    member do
      post 'manager'
      post 'approved'
    end
  end

  resources :promocodes

  resources :authorizations
  match '/auth/:provider/callback', to: 'authorizations#create'
  match '/auth/failure', to: 'authorizations#failure'

  root to: 'pages#index'
end
