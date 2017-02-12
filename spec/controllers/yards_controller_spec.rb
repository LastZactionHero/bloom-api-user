require 'rails_helper'

describe YardsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:zipcode) { '46240' }
  let(:zone) { '5B' }
  let(:yard) { FactoryGirl.create(:yard, user: user, zipcode: zipcode, zone: zone) }

  before do
    sign_in(user)
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe 'index' do
    it 'shows a list of yards belonging to the user' do
      yard
      yard_2 = FactoryGirl.create(:yard, user: user, zipcode: '22222', zone: '2B')
      other_user_yard = FactoryGirl.create(:yard, user: FactoryGirl.create(:user, email: 'another@user.com'), zipcode: '22222', zone: '2B')

      get(:index)
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      expect(body.map{|y| y['id']}.sort).to eq([yard.id, yard_2.id])
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      get(:index)
      expect(response.status).to eq(401)
    end
  end

  describe 'show' do
    it 'shows a yard' do
      get(:show, params: {id: yard.id})
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)

      expect(body['id']).to eq(yard.id)
      expect(body['zipcode']).to eq(zipcode)
      expect(body['zone']).to eq(zone)
    end

    it 'returns an error if the yard is not found' do
      get(:show, params: {id: yard.id + 1})
      expect(response.status).to eq(404)
    end

    it 'returns an error if the yard belongs to another user' do
      yard.update_attribute(:user, FactoryGirl.create(:user, email: 'another@user.com'))
      get(:show, params: { id: yard.id })
      expect(response.status).to eq(403)
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      get(:show, params: {id: yard.id})
      expect(response.status).to eq(401)
    end
  end

  describe 'create' do
    it 'creates a Yard' do
      expect(Yard.count).to eq(0) # Assumption

      post :create, params: { zone: zone, zipcode: zipcode }
      expect(response.status).to eq(201)

      yard = Yard.first
      expect(yard.zipcode).to eq(zipcode)
      expect(yard.zone).to eq(zone)
      expect(yard.user).to eq(user)
    end

    it 'returns a yard' do
      post :create, params: { zone: zone, zipcode: zipcode }
      expect(response.status).to eq(201)

      body = JSON.parse(response.body)
      expect(body['zipcode']).to eq(zipcode)
      expect(body['zone']).to eq(zone)
    end

    it 'raises an error on validation error' do
      post :create, params: { }
      expect(response.status).to eq(400)

      body = JSON.parse(response.body)
      expect(body['errors']['zone']).to include('can\'t be blank')
      expect(body['errors']['zipcode']).to include('can\'t be blank')
    end

    it 'raises an error if not signed in' do
      sign_out(user)
      post :create, params: { zone: zone, zipcode: zipcode }
      expect(response.status).to eq(401)
    end
  end

  describe 'update' do

    it 'updates a yard' do
      expect(yard.soil).not_to eq('moderate')
      patch(:update, params: { id: yard.id, zipcode: '11111', zone: '2A', soil: 'moderate' })
      expect(response.status).to eq(200)

      yard.reload
      expect(yard.zipcode).to eq('11111')
      expect(yard.zone).to eq('2A')
      expect(yard.soil).to eq('moderate')
    end

    it 'returns a yard' do
      expect(yard.soil).not_to eq('moderate')
      patch(:update, params: { id: yard.id, zipcode: '11111', zone: '2A', soil: 'moderate' })
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      expect(body['zipcode']).to eq('11111')
      expect(body['zone']).to eq('2A')
      expect(body['soil']).to eq('moderate')
    end

    it 'returns an error if the yard belongs to a different user' do
      yard.user = FactoryGirl.create(:user, email: 'another@user.com')
      yard.save

      patch(:update, params: { id: yard.id, zipcode: '11111', zone: '2A', soil: 'moderate' })
      expect(response.status).to eq(403)
    end

    it 'returns an error if data is invalid' do
      expect(yard.soil).not_to eq('moderate')
      patch(:update, params: { id: yard.id, soil: 'mushy' })
      expect(response.status).to eq(400)

      body = JSON.parse(response.body)
      expect(body['errors']['soil']).to include('is not included in the list')
    end

    it 'returns an error if not found' do
      patch(:update, params: { id: yard.id + 1, soil: 'mushy' })
      expect(response.status).to eq(404)
    end

    it 'returns an error if not signed in' do
      sign_out(user)
      patch(:update, params: { id: yard.id, zipcode: '11111', zone: '2A', soil: 'moderate' })
      expect(response.status).to eq(401)
    end

  end

  describe 'destroy' do
    it 'destroys a yard' do
      delete(:destroy, params: { id: yard.id })
      expect(response.status).to eq(200)

      expect(Yard.count).to eq(0)
    end

    it 'raises an error if the yard does not exist' do
      delete(:destroy, params: { id: yard.id + 1 })
      expect(response.status).to eq(404)
    end

    it 'raises an error if a different user owns the yard' do
      yard.user = FactoryGirl.create(:user, email: 'another@user.com')
      yard.save

      delete(:destroy, params: { id: yard.id })
      expect(response.status).to eq(403)
    end

    it 'raises an error if the user is not signed in' do
      sign_out(user)
      delete(:destroy, params: { id: yard.id })
      expect(response.status).to eq(401)
    end
  end
end