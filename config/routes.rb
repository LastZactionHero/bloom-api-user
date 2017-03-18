Rails.application.routes.draw do
  devise_for :users
  post '/users/sign_up', to: 'users#sign_up_user'
  post '/users/sign_in_as', to: 'users#sign_in_user'
  post '/users/sign_out', to: 'users#sign_out_user'
  get '/users/ping', to: 'users#ping'
  post '/users/upgrade', to: 'users#upgrade'
  get '/promo_codes/validate', to: 'promo_codes#validate'

  resources :yards, only: [:index, :show, :create, :update, :destroy]
  resources :beds, only: [:index, :show, :create, :update, :destroy] do
    member do
      patch :set_template
    end
  end
end
