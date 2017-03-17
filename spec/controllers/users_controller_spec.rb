require 'rails_helper'

describe UsersController do
  render_views

  let(:email) { 'user@site.com' }
  let(:password) { 'abc1234567' }

  before do
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe 'sign_up' do
    it 'creates a user' do
      expect(User.count).to eq(0) # Assumption

      post(:sign_up_user, params: { email: email, password: password })
      expect(response.status).to eq(201)

      # User is created
      expect(User.count).to eq(1)
      user = User.first
      expect(user.email).to eq(email)
      expect(user.valid_password?(password)).to be_truthy
      expect(user.account_status).to eq('trial')

      # User is returned
      body = JSON.parse(response.body)
      expect(body).to eq({'email' => user.email, 'account' => user.account})
    end

    it 'signs in' do
      post(:sign_up_user, params: { email: email, password: password })
      expect(session['warden.user.user.key'][0][0]).to eq(User.first.id)
    end

    it 'returns an error if the password is too short' do
      post(:sign_up_user, params: { email: email, password: '1234' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['password']).to include('is too short (minimum is 6 characters)')
    end

    it 'returns an error if the user already exists' do
      FactoryGirl.create(:user, email: email, password: password)

      post(:sign_up_user, params: { email: email, password: '1234' })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['email']).to include('has already been taken')
    end

    it 'returns an error if the email is not provided' do
      post(:sign_up_user, params: { password: password })
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

      # User is returned
      body = JSON.parse(response.body)
      expect(body).to eq({'email' => user.email, 'account' => user.account})
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

  describe 'ping' do
    let(:user) { FactoryGirl.create(:user, email: email, password: password) }

    it 'returns the user if signed in' do
      sign_in(user)
      get(:ping)
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body).to eq({'email' => user.email, 'account' => user.account})
    end

    it 'returns 401 if not signed in' do
      get(:ping)
      expect(response.status).to eq(401)
    end
  end

  describe 'upgrade' do
    let(:user) { FactoryGirl.create(:user, account_status: 'trial')}

    it 'upgrades to full_access' do
      VCR.use_cassette("upgrade_success") do
        sign_in(user)
        post(:upgrade, params: {token: {id: 'tok_19yQsmKSEf5qLSTcb23fFbSI'}})

        user.reload
        expect(user.account_status).to eq('full_access')

        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body).to eq({'email' => user.email, 'account' => user.account})
      end
    end

    it 'fails if the token is invalid' do
      VCR.use_cassette("upgrade_fail") do
        sign_in(user)
        post(:upgrade, params: {token: {id: 'tok_bad_token'}})

        user.reload
        expect(user.account_status).to eq('trial')

        expect(response.status).to eq(400)
        body = JSON.parse(response.body)
        expect(body).to eq({'error' => 'No such token: tok_bad_token'})
      end
    end

    it 'returns an error if the user is not signed in' do
      post(:upgrade, params: {token: {id: 'tok_12345'}})
      expect(response.status).to eq(401)
    end
  end
end
