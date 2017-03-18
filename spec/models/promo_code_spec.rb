require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  describe 'validations' do
    it 'validates code uniqueness' do
      code = 'abcd1234'
      pc_a = PromoCode.create(code: code)

      pc_b = PromoCode.create(code: code)
      expect(pc_b.errors['code']).to include('has already been taken')
    end

    it 'validates code presence' do
      pc = PromoCode.create# code is automatically set if blank
      pc.code = nil
      pc.save
      expect(pc.errors['code']).to include('can\'t be blank')
    end

    it 'creates successfully' do
      pc = PromoCode.create
      expect(pc.errors.any?).to be_falsey
    end
  end

  describe 'code' do
    it 'initializes with a code' do
      pc = PromoCode.create
      expect(pc.code.match(/[A-Z0-9]{8}/)).to be_present
    end
  end

  describe 'redeem_by_code!' do
    describe 'success' do
      it 'returns the PromoCode' do
        pc = FactoryGirl.create(:promo_code)
        result = PromoCode.redeem_by_code!(pc.code)
        expect(pc).to eq(result)

        pc_restricted = FactoryGirl.create(:promo_code, reusable: false, expiration: 1.day.from_now)
        expect(PromoCode.redeem_by_code!(pc_restricted.code)).to eq(pc_restricted)
      end

      it 'increments the use_count' do
        pc = FactoryGirl.create(:promo_code)
        expect(pc.use_count).to equal(0)
        PromoCode.redeem_by_code!(pc.code)
        expect(pc.reload.use_count).to equal(1)
      end
    end

    describe 'failure' do
      it 'returns an nil if the code is not valid' do
        expect(PromoCode.redeem_by_code!('not_a_real_code')).to be_nil
      end

      it 'returns an nil if the code is not reusable, and has already been used' do
        pc = FactoryGirl.create(:promo_code, reusable: false, use_count: 1)
        expect(PromoCode.redeem_by_code!(pc.code)).to be_nil
      end

      it 'returns an nil if the code is expired' do
        pc = FactoryGirl.create(:promo_code, expiration: 1.day.ago)
        expect(PromoCode.redeem_by_code!(pc.code)).to be_nil
      end
    end

  end
end
