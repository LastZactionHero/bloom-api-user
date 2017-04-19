require 'rest-client'



HOST_PROD = "http://api-search.plantwithbloom.com"
page_idx = 0
while true
  puts "Fetching Page: #{page_idx}"
  response = RestClient.post("#{HOST_PROD}/search/query", query: { common_name: '', height: {min: 0, max: 9999}, width: {min: 0, max: 9999}}, page_idx: page_idx)
  body = JSON.parse(response.body)
  break if body['plants'].count == 0

  body['plants'].each do |plant|
    puts "Building: #{plant['permalink']}"
    template = File.read("#{Rails.root}/lib/tasks/auto_plant_page_template.html")

    template.gsub!('X_COMMONNAME_X', plant['common_name'])
    template.gsub!('X_IMAGE_URL_X', plant['image_url'])

    description_text = [plant['description'], plant['key_features'].map{|f| "#{f['name']}."}, plant['special_features'].map{|f| "#{f['name']}."}].flatten.join(" ")

    size_text = []
    size_text << "#{plant['size']['avg_width']}&quot; W" if plant['size']['avg_width'].present?
    size_text << "#{plant['size']['avg_height']}&quot; H" if plant['size']['avg_height'].present?
    size_text = size_text.join(' X ')

    type_text = []
    type_text << plant['leave_type']['name'] if plant['leave_type']
    type_text << plant['plant_type']['name'] if plant['plant_type']
    type_text = type_text.join(" ")

    description_html = '<div>'
    description_html += "<p>#{description_text}</p>"
    description_html += "<div class='row'><div class='col-md-3'><strong>Size</strong></div><div class='col-md-9'>#{size_text}</div></div>"
    description_html += "<div class='row'><div class='col-md-3'><strong>Type</strong></div><div class='col-md-9'>#{type_text}</div></div>"
    description_html += "<div class='row'><div class='col-md-3'><strong>Flower Color</strong></div><div class='col-md-9'>#{plant['flower_color']['name']}</div></div>" if plant['flower_color']
    description_html += "<div class='row'><div class='col-md-3'><strong>Foliage Color</strong></div><div class='col-md-9'>#{plant['foliage_color']['name']}</div></div>" if plant['foliage_color']
    description_html += "<div class='row'><div class='col-md-3'><strong>Lighting</strong></div><div class='col-md-9'>#{plant['light_need']['name']}</div></div>" if plant['light_need']
    description_html += '</div>'

    template.gsub!("X_DETAILS_X", description_html)

    output = File.open("#{Rails.root}/scripts/auto_plant_html/#{plant['permalink']}.html", 'w')
    output << template
    output.close
  end
  page_idx += 1
end