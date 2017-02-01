require 'aws-sdk'
require 'yaml'

# get credentials
cred = YAML.load_file("credentials_dev.yml")

cred.each do | env,value |

# establish connection
ec2 = Aws::EC2::Client.new(
access_key_id: value["access_key_id"],
secret_access_key: value["secret_access_key"],
region: value["region"]
)

response=ec2.describe_instances

file=File.new("Environments_aws.md",'a+')

# markdown list of enviromnets
file.write "## #{env} " + "\n"
file.write '| key-name | public_ip_address | private_ip_address | image_id | instance_id | instance_type | availability_zone | state | virtualization_type ' + "\n"
file.write '| ---- | ----------------- | ------------------ | -------- | ----------- | ------------- | ----------------- | ----- | ------------------ ' + "\n"

response[:reservations].each do |reservation|
  reservation[:instances].each do |instance|
  #  file.write "|" + instance[:tags].first.value.to_s + "|"
    a = instance[:tags].select{|tag| tag.key == 'Name'}
    h = Hash[*a][:value].to_s
    file.write "|" + h  + "|"
    file.write instance[:public_ip_address].to_s + "|"
    file.write instance[:private_ip_address].to_s + "|"
    file.write instance[:image_id].to_s + "|"
    file.write instance[:instance_id].to_s + "|"
    file.write instance[:instance_type].to_s + "|"
    file.write instance[:placement][:availability_zone].to_s + "|"
    file.write instance[:state][:name].to_s + "|"
    file.write instance[:virtualization_type].to_s
    file.puts
  end
end
end
