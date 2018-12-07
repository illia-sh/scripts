import json
import boto3
from botocore.exceptions import ClientError

client = boto3.client('ec2')
regions_dict = client.describe_regions()
region_list = [region['RegionName'] for region in regions_dict['Regions']]

ec2 = boto3.resource('ec2')
all_groups = []
security_groups_in_use = []
# Get ALL security groups names
security_groups_dict = client.describe_security_groups()
security_groups = security_groups_dict['SecurityGroups']
for groupobj in security_groups:
    if groupobj['GroupName'] == 'default':
        security_groups_in_use.append(groupobj['GroupId'])
    all_groups.append(groupobj['GroupId'])

# Get all security groups used by instances
instances_dict = client.describe_instances()
reservations = instances_dict['Reservations']
network_interface_count = 0

for i in reservations:
    for j in i['Instances']:
        for k in j['SecurityGroups']:
            if k['GroupId'] not in security_groups_in_use:
                security_groups_in_use.append(k['GroupId'])
        # Security groups used by network interfaces
        for m in j['NetworkInterfaces']:
            network_interface_count += 1
            for n in m['Groups']:
                if n['GroupId'] not in security_groups_in_use:
                    security_groups_in_use.append(n['GroupId'])

# Security groups used by classic ELBs
elb_client = boto3.client('elb')
elb_dict = elb_client.describe_load_balancers()
for i in elb_dict['LoadBalancerDescriptions']:
    for j in i['SecurityGroups']:
        if j not in security_groups_in_use:
            security_groups_in_use.append(j)

# Security groups used by ALBs
elb2_client = boto3.client('elbv2')
elb2_dict = elb2_client.describe_load_balancers()
for i in elb2_dict['LoadBalancers']:
    for j in i['SecurityGroups']:
        if j not in security_groups_in_use:
            security_groups_in_use.append(j)

# Security groups used by RDS
rds_client = boto3.client('rds')
rds_dict = rds_client.describe_db_security_groups()

for i in rds_dict['DBSecurityGroups']:
    for j in i['EC2SecurityGroups']:
        if j not in security_groups_in_use:
            security_groups_in_use.append(j)

# need to add redis/eks/fargate/

delete_candidates = []
for group in all_groups:
    if group not in security_groups_in_use and not group.startswith('AWS-OpsWorks-'):
        delete_candidates.append(group)

####
#for group in delete_candidates:
#    security_group = ec2.SecurityGroup(group)
#    try:
#        security_group.delete()
#    except Exception as e:
#        print(e)
#        print("{0} requires manual remediation.".format(security_group.group_name))

print(delete_candidates)
print(u"Total number of Security Groups evaluated: {0:d}".format(len(security_groups_in_use)))
print(u"Total number of EC2 Instances evaluated: {0:d}".format(len(reservations)))
print(u"Total number of Load Balancers evaluated: {0:d}".format(len(elb_dict['LoadBalancerDescriptions']) + len(elb2_dict['LoadBalancers'])))
