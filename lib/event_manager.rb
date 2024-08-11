require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phone)
  cleaned_phone = phone.gsub(/[()\- .]/, '').to_s

  if cleaned_phone.length < 10
    p "Bad number!"
  elsif cleaned_phone.length > 10 and cleaned_phone[0] == 1
    p cleaned_phone[1..-1]
  elsif cleaned_phone.length > 10 and cleaned_phone[0] != 1
    p "Bad number!"
  else
    p cleaned_phone
  end
  
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('lib/secret.key').strip

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  home_phone = clean_phone_numbers(row[:homephone])

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end
