class UsersController < ApplicationController
  def sign_up_user
    @user = User.create(email: params[:email],
                       password: params[:password])

    if @user.errors.any?
      render status: 400, json: { errors: @user.errors }
    else
      sign_in(@user)
      render status: 201
    end
  end

  def sign_in_user
    @user = User.find_by(email: params[:email])
    unless @user
      render status: 400, json: { errors: { email: ['not found'] } }
      return
    end

    if @user.valid_password?(params[:password])
      sign_in(@user)
      render status: 201
    else
      render status: 400, json: { errors: { password: ['is incorrect'] } }
    end
  end

  def sign_out_user
    sign_out(current_user) if current_user
  end

  def ping
    head 401 unless current_user
  end

end
