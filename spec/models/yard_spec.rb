require 'rails_helper'

RSpec.describe Yard, type: :model do
  describe 'validations' do
    it 'requires a User' do
      yard = Yard.create
      expect(yard.errors[:user_id]).to include('can\'t be blank')
    end

    it 'requires a zipcode' do
      yard = Yard.create
      expect(yard.errors[:zipcode]).to include('can\'t be blank')
    end

    it 'requires a zone' do
      yard = Yard.create
      expect(yard.errors[:zone]).to include('can\'t be blank')
    end

    it 'validates successfully' do
      user = FactoryGirl.create(:user)
      yard = Yard.create(user: user, zone: '5B', zipcode: '46240')
      expect(yard.valid?).to be_truthy
    end

    it 'accepts valid soil types' do
      valid = %w(dry moderate wet)
      valid.each do |soil|
        yard = Yard.create(soil: soil)
        expect(yard.errors[:soil]).to be_empty
      end

      yard = Yard.create(soil: 'mushy')
      expect(yard.errors[:soil]).to include('is not included in the list')
    end
  end
end
