# - yard_id
# - name (string)
# - attached_to_house (boolean)
# - orientation (string) (north, south, east, west)
# - width (ft)
# - depth (ft)
# - sunlight_morning: (string) full_sun, partial_sun, partial_shade, full_shade, filtered_sun
# - sunlight_afternoon: (string) full_sun, partial_sun, partial_shade, full_shade, filtered_sun
# - watered (boolean)
class Bed < ApplicationRecord
  belongs_to :yard, optional: true
  validates_presence_of :yard_id
  validates_presence_of :width
  validates :width, numericality: { greater_than_or_equal_to: 2.0, less_than_or_equal_to: 100.0 }
  validates_presence_of :depth
  validates :depth, numericality: { greater_than_or_equal_to: 2.0, less_than_or_equal_to: 100.0 }
  validates :orientation, inclusion: { in: %w(north south east west) }, allow_nil: true
  validates :sunlight_morning, inclusion: { in: %w(full_sun partial_sun partial_shade full_shade filtered_sun) }, allow_nil: true
  validates :sunlight_afternoon, inclusion: { in: %w(full_sun partial_sun partial_shade full_shade filtered_sun) }, allow_nil: true
end
