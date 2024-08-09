# Using ruby CSV parser

require 'csv'
require 'google/apis/civicinfo_v2'

puts "EventManager Initialized"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def legislator_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('lib/secret.key').strip

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_string = legislator_names.join(', ')
  rescue
    'ZIPCODE NOT FOUND'
  end
end

contents = CSV.open(
  'event_attendees.csv', 
  headers: true,
  header_converters: :symbol
  )

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislator = legislator_by_zipcode(zipcode)

  puts "#{name} - #{zipcode} is rep by #{legislator}"
end

