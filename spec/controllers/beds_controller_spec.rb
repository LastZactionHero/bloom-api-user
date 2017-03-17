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

    it 'returns an error if a trial user and the yard already has one bed' do
      user.account_status = 'trial'
      user.save

      FactoryGirl.create(:bed, yard: yard)
      post(:create, params: { yard_id: yard.id, width: 30, depth: 6, watered: true })
      expect(response.status).to eq(403)
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

  describe 'set_template' do
    it 'updates template_id, returns a bed' do
      expect(bed.template_id).to be_nil

      template_id = 20
      patch :set_template, params: { id: bed.id, template_id: template_id}
      expect(response.status).to eq(200)

      bed.reload
      expect(bed.template_id).to eq(template_id)

      body = JSON.parse(response.body)
      expect(body['id']).to eq(bed.id)
      expect(body['template_id']).to eq(bed.template_id)
    end

    it 'clear existing template assignments' do
      bed.template_id = 20
      bed.template_placements = {a: 1}
      bed.template_plant_mapping = {a: 'planty'}
      bed.save

      patch :set_template, params: { id: bed.id, template_id: 21}
      expect(response.status).to eq(200)

      bed.reload
      expect(bed.template_id).to eq(21)
      expect(bed.template_placements).to eq({})
      expect(bed.template_plant_mapping).to eq({})
    end

    it 'returns an error if the template_id is not valid' do
      patch :set_template, params: { id: bed.id }
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body['errors']['template_id']).to eq(['is not valid'])
    end

    it 'runs find_and_authorize_bed' do

    end
  end

  describe 'update' do

    it 'updates the Bed' do
      expect(bed.orientation).not_to eq('south') # Assumption

      template_placements = [{'plant' => {'common_name' => 'planty'}}]
      template_plant_mapping =  [{'plant' => {'permalink' => 'shrub'}, 'templatePlant' => {'label' => 'V'}}]

      patch(:update, params: { id: bed.id,
                             orientation: 'south',
                             template_id: 1,
                             template_placements: template_placements,
                             template_plant_mapping: template_plant_mapping
                           })
      expect(response.status).to eq(200)

      bed.reload
      expect(bed.orientation).to eq('south')
      expect(bed.template_id).to eq(1)
      expect(bed.template_placements).to eq(template_placements)
      expect(bed.template_plant_mapping).to eq(template_plant_mapping)
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
