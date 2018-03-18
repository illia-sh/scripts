require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'chef-api'

#### Obtaining an API token¶
# chef-compliance settings
API_URL="https://www.chef-compliance.com:443/api"
REFRESH_TOKEN="6/D8uELUczQfjd8vgwhQNzO0b26yN549spJ......."
USER="compliance_USER"
ENVIRONMENT="Development"
SSH_KEY_ID="bd21ce25-cc20-4ad0-7fa0-43c87ca09292"

# chef-server connetion settings
CLIENT_ORG = 'https://api.opscode.com/organizations/my_org'
CLIENT_FLAVOR = :enterprise
CLIENT_NAME = 'client_name'
CLIENT_KEY_PATH   = '~/.chef/client_name.pem'

uri = URI.parse("#{API_URL}/access_token")
header = {'Content-Type': 'text/json'}
token = {  "token": "#{REFRESH_TOKEN}"}

# ssl
http = Net::HTTP.new(uri.host, uri.port)
if uri.port == 443;
  http.use_ssl = true
else
  http.use_ssl = false
end

http.verify_mode = OpenSSL::SSL::VERIFY_NONE # local test

# Create the HTTP objects
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = token.to_json

# Send the request
response = http.request(request)
API_TOKEN = JSON.parse(response.body)['access_token']
auth="Authorization: Bearer #{API_TOKEN}"
auth_header = {"Authorization": " Bearer #{API_TOKEN}","Content-Type": "application/json"}

# get users
## uri = URI("#{API_URL}/users")
## req = Net::HTTP::Get.new(uri)
## req['Authorization'] = " Bearer #{API_TOKEN}"
## get_users  = http.request(req)

# create chef_environment in compliance
env_uri = URI("#{API_URL}/owners/#{USER}/envs")
env_request = Net::HTTP::Post.new(env_uri.request_uri, auth_header)
env_request.body = {"name":"#{ENVIRONMENT}"}.to_json
http.request(env_request)

# connect to chef-server
include ChefAPI::Resource
ChefAPI.configure do |config|
  # The endpoint for the Chef Server. This can be an Open Source Chef Server,
  # Hosted Chef Server, or Enterprise Chef Server.
  config.endpoint = CLIENT_ORG
  config.flavor = CLIENT_FLAVOR
  config.client = CLIENT_NAME
  config.key    = CLIENT_KEY_PATH
  config.ssl_verify = false
  config.read_timeout = 120
end

# get chef nodes from specific env
results = Search.query(:node, "chef_environment:#{ENVIRONMENT}",start: 1); 0
puts "Found total #{results.total}"

# ssh user depends on platform
def login_user(user)
 case user
 when /ubuntu/
  'ubuntu'
when /debian/
  'root'
when /amazon/
   'ec2-user'
when /rhel/,/centos/,/redhat/
  'centos'
end
end

instances=[]
(0..results.total-1).each do |i|
 next if results.rows[i].nil?
  instances[i] = {
    "hostname": results.rows[i]['automatic']['ipaddress'],
    "name": results.rows[i]['name'],
    "environment": results.rows[i]['chef_environment'],
    "loginUser": login_user(results.rows[i]['automatic']['platform']),
    "loginMethod": "ssh",
    "loginKey": "#{SSH_KEY_ID}"
  }
  end

# push nodes from chef-server to chef-compliance
compl_uri = URI("#{API_URL}/owners/#{USER}/nodes")
req = Net::HTTP::Post.new(compl_uri.request_uri, auth_header)
req.body = instances.to_json
puts http.request(req).body
