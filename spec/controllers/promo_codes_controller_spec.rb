require 'rails_helper'

describe PromoCodesController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:promo_code) { FactoryGirl.create(:promo_code) }

  before do
    sign_in(user)
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe 'validate' do
    it 'returns an error if the user is not signed in' do
      sign_out(user)

      get(:validate)
      expect(response.status).to eq(401)
    end

    it 'returns successfully if the promo code is valid' do
      get(:validate, params: {code: promo_code.code})
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      expect(body['discount']).to eq(promo_code.discount)
      expect(body['discounted_price']).to be_present
    end

    it 'returns an error if the promo code is not valid' do
      get(:validate, params: {code: 'not_a_real_code'})
      expect(response.status).to eq(400)
    end
  end
end
