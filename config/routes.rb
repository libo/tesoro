Rails.application.routes.draw do
  resources :events
  resources :imports

  devise_for :users

  root to: "events#index"
end
