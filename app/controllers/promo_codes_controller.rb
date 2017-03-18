class PromoCodesController < ApplicationController
  before_action :validate_signed_in

  def validate
    @promo_code = PromoCode.validate_by_code(params[:code])
    unless @promo_code
      render status: 400, json: { errors: { code: ['is not valid']}}
      return
    end

    @discounted_price = @promo_code.discounted_price(Product.product_price)
  end
end
