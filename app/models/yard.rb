# - user_id
# - zipcode (string)
# - zone (string)
# - soil (string) (wet, moderate, dry)
# - preferred_plant_types (jsonb) (annuals, perennials,  deciduous_shrubs, evergreen_shrubs, evergreen_trees, shade_trees, ornamental_trees)
class Yard < ApplicationRecord
  belongs_to :user, optional: true
  has_many :beds

  validates_presence_of :user_id
  validates_presence_of :zipcode
  validates_presence_of :zone
  validates :soil, inclusion: { in: %w(dry moderate wet) }, allow_nil: true
end
