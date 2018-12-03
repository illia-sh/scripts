##### filter instances by tag and list by id
```
instance_list=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=customvalue" --query 'Reservations[*].Instances[*].InstanceId' --profile development | jq .[][] | tr -d '"')
```

##### tag instances from instance_list with {"awsinspector":"true"}
```
for i in $instance_list ; do aws ec2 create-tags --resources $i --tags Key=awsinspector,Value=true --profile development ; done
```
