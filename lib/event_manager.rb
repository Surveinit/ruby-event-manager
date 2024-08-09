# puts 'Event Manager Initialized!'

# lines = File.readlines('event_attendees.csv')

# # Skipping the header dynamically
# lines.each_with_index do |line, index|
#   next if index == 0
#   columns = line.split(',')
#   names = columns[2]
#   p names
# end


# Using ruby CSV parser

require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = File.read('lib/secret.key').strip

puts "EventManager Initialized"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

contents = CSV.open(
  'event_attendees.csv', 
  headers: true,
  header_converters: :symbol
  )

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    legislators = legislators.officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  puts "#{name} - #{zipcode} is rep by #{legislators}"
end

