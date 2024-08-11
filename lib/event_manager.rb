require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

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

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phone)
  cleaned_phone = phone.gsub(/[()\- .]/, '').to_s

  if cleaned_phone.length < 10
    "Bad number!"
  elsif cleaned_phone.length > 10 and cleaned_phone[0] == 1
    cleaned_phone[1..-1]
  elsif cleaned_phone.length > 10 and cleaned_phone[0] != 1
    "Bad number!"
  else
    cleaned_phone
  end
  
end

def clean_datetime(date)
  Time.strptime(date, "%m/%d/%y %H:%M")
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

hours = []
reg_in_days = []
days_of_week = {
  0 => "Sunday",
  1 => "Monday",
  2 => "Tuesday",
  3 => "Wednesday",
  4 => "Thursday",
  5 => "Friday",
  6 => "Sunday"

}

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  # zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  
  # ------ Assignment 1 ------ #
  p home_phone = clean_phone_numbers(row[:homephone])
  
  # ------ Assignment 2 ------ #
  reg_date = clean_datetime(row[:regdate]) 
  reg_hour = reg_date.strftime("%H")
  hours.push(reg_hour)

  # ------ Assignment 3 ------#
  reg_day = reg_date.wday
  reg_in_days.push(reg_day)
  # p reg_date
  
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id,form_letter)
end

# ------ Ass 2 contd ------ #
peak_hours = Hash.new(0)
hours.each {|hour| peak_hours[hour] += 1}
most_peak_hour = peak_hours.sort_by {|hour, counts| counts}.last[0]
p "Which hours of the day are the most people registered? => #{most_peak_hour}hrs"

# ------ Ass 3 contd ------ #
most_reg_days = Hash.new(0)
reg_in_days.each {|day| most_reg_days[day] += 1}
most_reg_day = most_reg_days.sort_by {|day, counts| counts}.last[0]

p "What days of the week did most people register? => #{days_of_week[most_reg_day]}"