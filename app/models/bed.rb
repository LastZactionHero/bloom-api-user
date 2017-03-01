# == Schema Information
#
# Table name: beds
#
#  id                         :integer          not null, primary key
#  yard_id                    :integer
#  name                       :string
#  attached_to_house          :boolean          default(FALSE)
#  orientation                :string
#  width                      :float
#  depth                      :float
#  sunlight_morning           :string
#  sunlight_afternoon         :string
#  watered                    :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  api_bed_tmpl_id            :integer
#  api_bed_tmpl_placements    :jsonb
#  api_bed_tmpl_plant_mapping :jsonb
#  template_id                :integer
#  template_placements        :jsonb
#  template_plant_mapping     :jsonb
#
# Indexes
#
#  index_beds_on_yard_id  (yard_id)
#

class Bed < ApplicationRecord
  belongs_to :yard, optional: true
  validates_presence_of :yard_id
  validates_presence_of :width
  validates :width, numericality: { greater_than_or_equal_to: 2.0, less_than_or_equal_to: 100.0 }
  validates_presence_of :depth
  validates :depth, numericality: { greater_than_or_equal_to: 2.0, less_than_or_equal_to: 100.0 }
  validates :orientation, inclusion: { in: %w(north south east west) }, allow_nil: true
  validates :sunlight_morning, inclusion: { in: %w(full_sun partial_sun partial_shade full_shade filtered_sun filtered_shade) }, allow_nil: true
  validates :sunlight_afternoon, inclusion: { in: %w(full_sun partial_sun partial_shade full_shade filtered_sun filtered_shade) }, allow_nil: true
  validates :sunlight_afternoon, inclusion: { in: %w(full_sun partial_sun partial_shade full_shade filtered_sun filtered_shade) }, allow_nil: true
  validates :template_id, numericality: { only_integer: true, greater_than_or_equal_to: 1, message: 'is not valid' }, allow_nil: true
end
