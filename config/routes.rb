TrackerApi::Application.routes.draw do
  devise_for :users

  root to: "games#index"

  resource :authentication_token, only: [:create, :destroy]
end
