require 'rails_helper'

RSpec.describe Bed, type: :model do
  describe 'validations' do
    it 'requires a Yard' do
      bed = Bed.create
      expect(bed.errors[:yard_id]).to include('can\'t be blank')
    end

    it 'requires a width, greater than 2, less than 100' do
      bed = Bed.create
      expect(bed.errors[:width]).to include('can\'t be blank')
      bed = Bed.create(width: 1.9)
      expect(bed.errors[:width]).to include('must be greater than or equal to 2.0')
      bed = Bed.create(width: 100.1)
      expect(bed.errors[:width]).to include('must be less than or equal to 100.0')
    end

    it 'requires a depth' do
      bed = Bed.create
      expect(bed.errors[:depth]).to include('can\'t be blank')
      bed = Bed.create(depth: 1.9)
      expect(bed.errors[:depth]).to include('must be greater than or equal to 2.0')
      bed = Bed.create(depth: 100.1)
      expect(bed.errors[:depth]).to include('must be less than or equal to 100.0')
    end

    it 'validates successfully' do
      bed = Bed.create(yard: FactoryGirl.create(:yard), width: 2.0, depth: 100.0)
      expect(bed.valid?).to be_truthy
    end

    it 'validates orientation is in list' do
      orientations = %w(north south east west)
      orientations.each do |orientation|
        bed = Bed.create(orientation: orientation)
        expect(bed.errors[:orientation]).to be_empty
      end
      bed = Bed.create(orientation: 'northly')
      expect(bed.errors[:orientation]).to include('is not included in the list')
    end    
  end
end
