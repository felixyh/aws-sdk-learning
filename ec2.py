import os
import boto3

ec2 = boto3.client('ec2')

response = ec2.describe_instances()
for item in response['Reservations']:
    for i in item['Instances']:
        print(
            i['KeyName'], 
            i['LaunchTime'], 
            i['State']['Name'], 
            [tag['Key'] + ":" + tag['Value'] for tag in i['Tags']],
            ["GroupName:" + sg['GroupName'] for sg in i['SecurityGroups']]
            )



# response = ec2.describe_regions()
# print('Regions:', response['Regions'])

# response = ec2.describe_availability_zones()
# print('Availability Zones:', response['AvailabilityZones'])