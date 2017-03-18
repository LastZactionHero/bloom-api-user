# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  code       :string
#  discount   :float            default(0.0)
#  reusable   :boolean          default(TRUE)
#  use_count  :integer          default(0)
#  expiration :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_promo_codes_on_code  (code)
#

class PromoCode < ApplicationRecord
  DEFAULT_CODE_LENGTH = 8

  validates_uniqueness_of :code
  validates_presence_of :code

  before_validation :init_code, on: :create

  def self.validate_by_code(code)
    promo_code = PromoCode.find_by(code: code)

    unless promo_code &&
      (promo_code.reusable || promo_code.use_count == 0) &&
      (promo_code.expiration.blank? || promo_code.expiration > DateTime.now)
      return nil
    end

    promo_code
  end

  def self.redeem_by_code!(code)
    promo_code = validate_by_code(code)
    if promo_code
      promo_code.use_count += 1
      promo_code.save
      promo_code
    else
      nil
    end
  end

  def discounted_price(product_price)
    (((100 - self.discount) / 100.0) * product_price).round(2)
  end

  private

  def init_code
    return true if self.code.present?

    code_characters= ('A'..'Z').to_a + ('0'..'9').to_a
    %w(O 0 1 I).each{|remove_character| code_characters.delete(remove_character)}
    self.code ||= DEFAULT_CODE_LENGTH.times.map{ code_characters.sample }.join('')
  end

end
