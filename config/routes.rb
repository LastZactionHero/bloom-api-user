Rails.application.routes.draw do
  devise_for :users
  post '/users/sign_up', to: 'users#sign_up_user'
  post '/users/sign_in_as', to: 'users#sign_in_user'
  post '/users/sign_out', to: 'users#sign_out_user'
  get '/users/ping', to: 'users#ping'

  resources :yards, only: [:index, :show, :create, :update, :destroy]
  resources :beds, only: [:index, :show, :create, :update, :destroy]
end
