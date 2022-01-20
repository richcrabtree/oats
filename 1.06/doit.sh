#!/bin/bash

VOLUMES=$(aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=example-asg-20220111194037777400000005"  --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId[]' --region us-west-2)
echo $VOLUMES

T1="{\
    \"Resources\": $VOLUMES,\
    \"Tags\": [\
        {\
            \"Key\": \"required\",\
            \"Value\": \"true\"\
        }\
    ]\
}"

aws --region us-west-2 ec2 create-tags  --cli-input-json "$T1"

INSTANCES=$(aws autoscaling describe-auto-scaling-groups --region us-west-2 --filters "Name=tag:Name,Values=example-asg" | jq '.AutoScalingGroups[].Instances[].InstanceId')
INSTANCES=$(echo "$INSTANCES" | tr -d '"')
echo $INSTANCES
aws --region us-west-2 ec2 create-tags  --tags "Key=required2,Value=true" --resources $INSTANCES
