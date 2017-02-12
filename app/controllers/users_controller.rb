class UsersController < ApplicationController
  def sign_up_user
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    if password && password != password_confirmation
      render status: 400, json: { errors: { password_confirmation: ['does not match']} }
      return
    end

    user = User.create(email: params[:email],
                       password: params[:password],
                       password_confirmation: params[:password_confirmation])

    if user.errors.any?
      render status: 400, json: { errors: user.errors }
    else
      sign_in(user)
      render status: 204, nothing: true
    end
  end

  def sign_in_user
    user = User.find_by(email: params[:email])
    unless user
      render status: 400, json: { errors: { email: ['not found'] } }
      return
    end

    if user.valid_password?(params[:password])
      sign_in(user)
      render status: 201, nothing: true
    else
      render status: 400, json: { errors: { password: ['is incorrect'] } }
    end
  end

  def sign_out_user
    sign_out(current_user) if current_user
  end
end