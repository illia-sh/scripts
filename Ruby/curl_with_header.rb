#!/usr/bin/env ruby
require 'net/https'
require 'uri'

start_time = Time.now.to_f

uri = URI.parse('http://bigroi.ru')
http = Net::HTTP.new(uri.host, uri.port)
if uri.port == 443;http.use_ssl = true else http.use_ssl = false end
http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this

request = Net::HTTP::Get.new(uri.request_uri)
request.add_field('User-Agent','Test-user-agent')

response = http.request(request)
total_time = Time.now.to_f - start_time
status_code = response.code
if status_code == "200"
   puts total_time
  else
  puts "-1"
end
