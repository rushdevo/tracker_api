TrackerApi::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'users', passwords: 'passwords' }

  root to: "games#index"

  resource :authentication_token, only: [:create, :destroy]
  resources :invitations, only: [:index, :new, :create, :update]
  resources :friendships, only: [:index, :destroy]
end
