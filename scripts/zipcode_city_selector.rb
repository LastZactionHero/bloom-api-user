# Produces a CSV of City/States with Zipcodes, one zipcode per city
require 'csv'

# Read the raw data file of cities and zipcodes
zipcode_city_raw = CSV.read("#{Rails.root}/scripts/zipcode_city.csv"); 0
zipcode_city_raw.shift; 0

# Collect them into cities, with one zipcode representing the city
# Count the number of refernces to the city
city_zipcode_map = {}

zipcode_city_raw.each do |zipcode_city_row|
  zipcode = zipcode_city_row[0]
  next if zipcode.match?(/[A-Z]/)
  key = "#{zipcode_city_row[4]}_#{zipcode_city_row[5]}".downcase.gsub(/[^a-z]/, '_')
  if city_zipcode_map.has_key?(key)
    city_zipcode_map[key][:zipcode_count] += 1
  else
    city_zipcode_map[key] = { zipcode: zipcode_city_row[0], city: zipcode_city_row[4], state: zipcode_city_row[5], zipcode_count: 1}
  end
end; 0

# Sort by number of zipcodes in the city
city_zipcode_values = city_zipcode_map.map{|k, v| v}; 0
city_zipcode_values.sort!{|a,b| b[:zipcode_count] <=> a[:zipcode_count]}; 0

CSV.open("#{Rails.root}/scripts/top_cities_by_zipcode.csv", "wb") do |csv|
  city_zipcode_values.first(1000).each do |city_zipcode_value|
    csv << [city_zipcode_value[:zipcode], city_zipcode_value[:city], city_zipcode_value[:state]]
  end
end
