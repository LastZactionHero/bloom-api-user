require 'rails_helper'

describe BedsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:yard) { FactoryGirl.create(:yard, user: user) }
  let(:neighbors_yard) { FactoryGirl.create(:yard, user: FactoryGirl.create(:user, email: 'another@user.com')) }
  let(:bed) { FactoryGirl.create(:bed, yard: yard) }
  let(:neighbors_bed) { FactoryGirl.create(:bed, yard: neighbors_yard) }

  before do
    sign_in(user)
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe 'create' do
    it 'creates a Bed' do
      expect(Bed.count).to eq(0)

      post(:create, params: { yard_id: yard.id, width: 30, depth: 6, watered: true })
      expect(response.status).to eq(201)

      bed = Bed.first
      expect(bed.yard).to eq(yard)
      expect(bed.watered).to be_truthy
    end

    it 'returns an error if the Yard does not exist' do
      post(:create, params: { yard_id: yard.id + 1, width: 30, depth: 6 })
      expect(response.status).to eq(404)
    end

    it 'returns an error if the Yard does not belong to the user' do
      post(:create, params: { yard_id: neighbors_yard.id, width: 30, depth: 6 })
      expect(response.status).to eq(403)
    end

    it 'returns an error if the Bed is invalid' do
      post(:create, params: { yard_id: yard.id })
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['width']).to include('must be greater than or equal to 2.0')
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      post(:create, params: { yard_id: yard.id, width: 30, depth: 6 })
      expect(response.status).to eq(401)
    end
  end

  describe 'update' do

    it 'updates the Bed' do
      expect(bed.orientation).not_to eq('south') # Assumption

      patch(:update, params: { id: bed.id, orientation: 'south'})
      expect(response.status).to eq(200)

      bed.reload
      expect(bed.orientation).to eq('south')
    end

    it 'returns an error if the Bed is invalid' do
      expect(bed.orientation).not_to eq('south') # Assumption

      patch(:update, params: { id: bed.id, orientation: 'nast'})
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['orientation']).to include('is not included in the list')
    end

    it 'returns an error if the Bed belongs to another user' do
      patch(:update, params: { id: neighbors_bed.id, orientation: 'south'})
      expect(response.status).to eq(403)
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      patch(:update, params: { id: bed.id, orientation: 'south'})
      expect(response.status).to eq(401)
    end

    it 'returns an error if the bed does not exist' do
      patch(:update, params: { id: bed.id + 1, orientation: 'south'})
      expect(response.status).to eq(404)
    end
  end

  describe 'destroy' do
    it 'destroys the bed' do
      delete(:destroy, params: { id: bed.id })
      expect(response.status).to eq(200)

      expect(Bed.count).to eq(0)
    end

    it 'returns an error if the bed belongs to another user' do
      delete(:destroy, params: { id: neighbors_bed.id })
      expect(response.status).to eq(403)
    end

    it 'returns an error if the bed does not exist' do
      delete(:destroy, params: { id: bed.id + 1})
      expect(response.status).to eq(404)
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      delete(:destroy, params: { id: bed.id})
      expect(response.status).to eq(401)
    end
  end

  describe 'show' do
    it 'shows the bed' do
      get(:show, params: { id: bed.id })
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      expect(body['id']).to eq(bed.id)
    end

    it 'returns an error if the bed belongs to another user' do
      get(:show, params: { id: neighbors_bed.id })
      expect(response.status).to eq(403)
    end

    it 'returns an error if the bed does not exist' do
      get(:show, params: { id: bed.id + 1})
      expect(response.status).to eq(404)
    end

    it 'returns an error if the user is not signed in' do
      sign_out(user)
      get(:show, params: { id: bed.id })
      expect(response.status).to eq(401)
    end
  end
end
