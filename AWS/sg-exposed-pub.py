import boto3
import csv

ec2 = boto3.resource('ec2')

sg_groups = ec2.security_groups.filter(Filters=[{
 'Name': 'ip-permission.cidr',
 'Values': ['0.0.0.0/0']}])

sg_list = []

for sg in sg_groups:
    for i in sg.ip_permissions:
        for ip in i['IpRanges']:
            if ip['CidrIp'] == '0.0.0.0/0':
                if i.get('FromPort') != None:
                    if i['FromPort'] == -1 or i['ToPort'] == -1:
                    #    print(i,i['FromPort'])
                        port = -1
                    else:
                        if i['FromPort'] == i['ToPort']:
                        #    print(i,"TTEST",i['FromPort'])
                            port = i['FromPort']
                        else:
                            port = (str(i['FromPort']) + ':' + str(i['ToPort']))
                else:
                    port = 0
                sg_list.append((sg.id,sg.group_name,port,sg.vpc_id))

with open('sg_exposed_to_pub.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(("group_id", "group_name", "open_port", "vpc_id"))
    for row in sg_list:
        print(row)
        writer.writerow(row)
