import boto3
import csv
from collections import defaultdict

ec2 = boto3.resource('ec2')

sg_groups = ec2.security_groups.filter(Filters=[{
 'Name': 'ip-permission.cidr',
 'Values': ['0.0.0.0/0']}])

default = 0
sg_info = defaultdict()
for sg in sg_groups:
    for i in sg.ip_permissions:
        for ip in i['IpRanges']:
            if ip['CidrIp'] == '0.0.0.0/0':
                if i.get('FromPort') != None:
                    if i['FromPort'] == -1 or i['ToPort'] == -1:
                        port = -1
                    else:
                        if i['FromPort'] == i['ToPort']:
                            port = i['FromPort']
                        else:
                            port = (i['FromPort'] + ':' + i['ToPort'])
                else:
                    port = 0

    # add securitygroup info
    sg_info[sg.id] = {
    'group_id': sg.id,
    'group_name': sg.group_name,
    'open_port': port,
    'vpc_id' : sg.vpc_id
    }

with open('test.csv', mode='w') as csv_file:
    fieldnames = ['group_id', 'group_name', 'open_port','vpc_id']
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    writer.writeheader()
    for sg_id, sg in sg_info.items():
        writer.writerow({'group_id': sg['group_id'], 'group_name': sg['group_name'],'open_port':sg['open_port'],"vpc_id":sg['vpc_id']})
