Rails.application.routes.draw do
  devise_for :users
  post '/users/sign_up', to: 'users#sign_up_user'
  post '/users/sign_in', to: 'users#sign_in_user'
  get '/users/sign_out', to: 'users#sign_out_user'

  resources :yards, only: [:index, :show, :create, :update, :destroy]
  resources :beds, only: [:index, :show, :create, :update, :destroy]
end
