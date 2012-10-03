TrackerApi::Application.routes.draw do
  resources :invitations

  devise_for :users, controllers: { registrations: 'users', passwords: 'passwords' }

  root to: "games#index"

  resource :authentication_token, only: [:create, :destroy]

  resources :invitations, only: [:create, :update]
end
