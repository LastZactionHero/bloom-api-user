FactoryGirl.define do
  factory :bed do
    yard_id 1
    template_id nil
    name "Front Yard Bed"
    attached_to_house false
    orientation "north"
    width 30
    depth 6
    sunlight_morning nil
    sunlight_afternoon nil
    watered false
  end
end
