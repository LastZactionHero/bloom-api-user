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

  def upgrade
    unless current_user
      render status: 401, json: {}
      return
    end

    @user = current_user

    Stripe.api_key = ENV['STRIPE_KEY_SECRET']

    token = params[:token][:id]

    begin
      charge = Stripe::Charge.create(
        :amount => 1499,
        :currency => 'usd',
        :description => "Unlimited Access 1 Year",
        :source => token,
      )
    rescue Stripe::InvalidRequestError => e
      render status: 400, json: { error: e.message }
      return
    end

    if charge.status == 'succeeded'
      @user.account_status = 'full_access'
      @user.account['payments'] << charge
      @user.save
    else
      render status: 400, json: {}
      return
    end

  end

end
