require 'rest-client'
require 'csv'

namespace :auto_city_page_generator do

  task :generate => :environment do
    user = User.find_by(email: 'auto@pb.dev') # abcd1234
    city_zipcodes = CSV.read("#{Rails.root}/scripts/top_cities_by_zipcode.csv"); 0
      yards = user.yards
    yards.each do |yard|
      begin
        # Identify City and State
        zipcode_row = city_zipcodes.find{|row| row[0] == yard.zipcode}
        city = zipcode_row[1]
        state = zipcode_row[2]

        yard_page_html = File.read("#{Rails.root}/lib/tasks/auto_city_page_template.html")
        yard_page_html.gsub!('XCITY_NAMEX', city)
        yard_page_html.gsub!('XSTATE_NAMEX', state)

        beds_html = yard.beds.order('id ASC').map do |bed|
          sunlight = if bed.sunlight_morning && bed.sunlight_afternoon
              'Full sun'
            elsif bed.sunlight_morning && !bed.sunlight_afternoon
              'Morning sun, afternoon shade'
            elsif !bed.sunlight_morning && bed.sunlight_afternoon
              'Morning shade, afternoon sun'
            else
              'Full shade'
          end
          placement = "#{bed.orientation.capitalize}-facing"
          placement += ', attached to house' if bed.attached_to_house

          image_name = "./images/yard_#{yard.id}_#{bed.name.gsub(/[^A-z]/, '_').gsub(/_+/, '_')}.png"

          bed_html = "<div class='bed'><div class='row'><div class='col-xs-12'><div class='bed-header'>"
          bed_html += "<div class='bed-title'>#{bed.name} <span class='bed-dimensions'>(#{bed.width}' W x #{bed.depth}' H)</span>"
          bed_html += "<div class='bed-description'>#{sunlight}, #{placement}</div>"
          bed_html += "</div></div>"
          bed_html += "<div class='row'>"
          bed_html += "<div class='col-xs-12 col-sm-8'>"
          bed_html += "<img src='#{image_name}' width=100% />"
          bed_html += "</div>"
          bed_html += "<div class='col-xs-12 col-sm-4'>"
          bed.template_plant_mapping.each do |key, plant|
            image_url = plant['image_url']
            common_name = plant['common_name']
            bed_html += "<div class='col-xs-4 plant-image' style='background-image: url(&quot;#{image_url}&quot;);'><div class='plant-label'>#{key}: #{common_name}</div></div>"
          end
          bed_html += "</div>"
          bed_html += "</div></div></div></div>"
          bed_html
        end.join('')
        yard_page_html.gsub!('XBED_CONTAINERX', beds_html)

        location_slug = "#{city.downcase}_#{state.downcase}".gsub(/[^A-z ]/, '').gsub(/\s+/, '_')
        yard_filename = "#{Rails.root}/scripts/auto_yard_html/#{location_slug}.html"
        file = File.open(yard_filename, 'w')
        file << yard_page_html
        file.close
      rescue NoMethodError
        puts "Failed: Yard #{yard.id}"
      end
    end
  end

end
