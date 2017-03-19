# == Schema Information
#
# Table name: yards
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  zipcode               :string
#  zone                  :string
#  soil                  :string
#  preferred_plant_types :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_yards_on_user_id  (user_id)
#  index_yards_on_zipcode  (zipcode)
#  index_yards_on_zone     (zone)
#
class Yard < ApplicationRecord
  belongs_to :user, optional: true
  has_many :beds, dependent: :destroy

  validates_presence_of :user_id
  validates_presence_of :zipcode
  validates_presence_of :zone
  validates :soil, inclusion: { in: %w(dry normal wet) }, allow_nil: true
end
