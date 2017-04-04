require 'rest-client'

# user = User.create(email: 'auto@pb.dev', password: 'abcd1234', password_confirmation: 'abcd1234')
user = User.find_by(email: 'auto@pb.dev')
yard = user.yards.last

yard.beds.destroy_all

beds_data = [
  { name: 'Front Yard, Porch', attached_to_house: true, orientation: 0, width: (26..30).to_a, depth: (5..7).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
  { name: 'Front Yard, Side of Driveway', attached_to_house: true, orientation: 0, width: (14..16).to_a, depth: (4..6).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
  { name: 'Side Yard', attached_to_house: true, orientation: 1, width: (26..30).to_a, depth: (5..7).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
  { name: 'Back Yard, Beneath Porch', attached_to_house: true, orientation: 2, width: (14..16).to_a, depth: (4..6).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
  { name: 'Back Yard, Along Fence', attached_to_house: true, orientation: 2, width: (26..30).to_a, depth: (5..7).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
  { name: 'Back Yard, Corner', attached_to_house: false, orientation: 2, width: (4..6).to_a, depth: (4..6).to_a, watered: false, soil: 'normal', sunlight_morning: nil, sunlight_afternoon: nil},
]

# Create the Yard
zipcode = '46240'
soil = 'normal'
zone = JSON.parse(RestClient.get("http://api:3000/zones/search?zipcode=#{zipcode}").body)['zone']
# yard = Yard.create(user_id: user.id, zipcode: zipcode, zone: zone, soil: soil)

# Create the Beds
orientation_offset = [0,1,2,3].sample

beds_data.each do |bed_data|
  bed = Bed.new
  bed.yard_id = yard.id
  bed.name = bed_data[:name]
  bed.attached_to_house = bed_data[:attached_to_house]
  bed.orientation = %w(north east south west)[bed_data[:orientation] + orientation_offset % 4]
  bed.width = bed_data[:width].sample
  bed.depth = bed_data[:depth].sample
  bed.sunlight_morning = %w(east south).include?(bed.orientation)
  bed.sunlight_afternoon = %w(west north).include?(bed.orientation)
  bed.soil = bed_data[:soil]
  bed.watered = bed_data[:watered]
  bed.save
end

yard.reload

yard.beds.each do |bed|
  puts "Start Bed"

  # Pick a template
  response = RestClient.get("http://api-search.plantwithbloom.com/bed_templates/suggestions?width=#{bed.width}&depth=#{bed.depth}")
  body = JSON.parse(response.body)
  template = body.slice(0..2).sample
  puts template.inspect
  bed.template_id = template['id']
  bed.save

  # For each plant...
  template_plants = template['template_plants'].compact
  template_plants.each do |template_plant|
    puts "Template Plant"
    puts template_plant.inspect

    # Build the query
    query = template_plant['search_query']
    query['zones'] = [yard.zone]
    query['soil_moisture'] = bed.soil

    if bed.sunlight_morning && bed.sunlight_afternoon
      query['lighting'] = 'full_shade'
    elsif !bed.sunlight_morning && bed.sunlight_afternoon
      query['lighting'] = 'afternoon'
    elsif bed.sunlight_morning && !bed.sunlight_afternoon
      query['lighting'] = 'morning'
    else
      query['lighting'] = 'full_shade'
    end

    max_width = [bed.depth, bed.width].min * 12
    query['width']['max'] = [max_width, query['width']['max']].min

    too_small_red_prop = 0.8
    if query['width']['min'] > query['width']['max'] * too_small_red_prop
      query['width']['min'] = (query['width']['max'] * too_small_red_prop).floor
    end

    puts "Query"
    puts query.inspect

    # Run the query
    response = RestClient.post("http://api-search.plantwithbloom.com/search/query", query: query)
    body = JSON.parse(response.body)

    puts "Picking Plant"
    # Select a plant
    plant = body['plants'].slice(0..2).sample
    puts plant.inspect
    bed.template_plant_mapping[template_plant['label']] = plant
    debugger if plant.nil?
    bed.save
  end

  # Render the bed
  puts "Rendering Bed"
  puts bed.template_plant_mapping.inspect
  permalink_mapping = {}
  bed.template_plant_mapping.each{|k,v| permalink_mapping[k] = v['permalink']}
  puts "Mapping"
  puts permalink_mapping.inspect
  response = RestClient.get("http://api-search.plantwithbloom.com/bed_templates/#{bed.template_id}/placements",
    params: {
      width: bed.width * 12,
      height: bed.depth * 12,
      template_plant_mapping: permalink_mapping})
  placements = JSON.parse(response.body)
  puts "placements response:"
  puts placements
  bed.template_placements = placements['placements']
  bed.save
end