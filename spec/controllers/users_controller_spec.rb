require 'rails_helper'

describe UsersController do
  let(:email) { 'user@site.com' }
  let(:password) { 'abc1234567' }

  describe 'sign_up' do
    it 'creates a user' do
      expect(User.count).to eq(0) # Assumption

      post(:sign_up_user, params: { email: email, password: password, password_confirmation: password })
      expect(response.status).to eq(204)

      expect(User.count).to eq(1)
      user = User.first
      expect(user.email).to eq(email)
      expect(user.valid_password?(password)).to be_truthy
    end

    it 'signs in' do
      post(:sign_up_user, params: { email: email, password: password, password_confirmation: password })
      expect(session['warden.user.user.key'][0][0]).to eq(User.first.id)
    end

    it 'returns an error if the password is too short' do
      post(:sign_up_user, params: { email: email, password: '1234', password_confirmation: '1234' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['password']).to include('is too short (minimum is 6 characters)')
    end

    it 'returns an error if the passwords do not match' do
      post(:sign_up_user, params: { email: email, password: password, password_confirmation: 'differentpassword' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['password_confirmation']).to include('does not match')
    end

    it 'returns an error if the user already exists' do
      FactoryGirl.create(:user, email: email, password: password)

      post(:sign_up_user, params: { email: email, password: '1234', password_confirmation: '1234' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['email']).to include('has already been taken')
    end

    it 'returns an error if the email is not provided' do
      post(:sign_up_user, params: { password: password, password_confirmation: password })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['email']).to include('can\'t be blank')
    end
  end

  describe 'sign_in' do
    let(:user) { FactoryGirl.create(:user, email: email, password: password) }

    it 'signs in the user' do
      post(:sign_in_user, params: { email: user.email, password: password })
      expect(response.status).to eq(201)
      expect(session['warden.user.user.key'][0][0]).to eq(user.id)
    end

    it 'returns an error if the email is not found' do
      post(:sign_in_user, params: { email: 'someone@else.com', password: password })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['email']).to include('not found')
    end

    it 'returns an error if the password is incorrect' do
      post(:sign_in_user, params: { email: user.email, password: 'wrongpassword' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['password']).to include('is incorrect')
    end
  end

  describe 'sign_out' do
    let(:user) { FactoryGirl.create(:user, email: email, password: password) }
    it 'signs out the user' do
      sign_in(user)
      expect(session['warden.user.user.key'][0][0]).to eq(user.id) # Assumption

      post(:sign_out_user)
      expect(session).to be_empty
    end
  end
end