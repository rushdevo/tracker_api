TrackerApi::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'users', passwords: 'passwords' }

  root to: "games#index"

  resource :authentication_token, only: [:create, :destroy]

  resources :friendships, only: [:index, :destroy]

  resources :games, only: [:index, :create, :update]

  resources :invitations, only: [:index, :new, :create, :update]
end
