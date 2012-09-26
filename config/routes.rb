TrackerApi::Application.routes.draw do
  devise_for :users

  root to: "games#index"
end
