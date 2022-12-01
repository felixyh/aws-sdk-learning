import os
import boto3

# s3 = boto3.resource('s3')

# for bucket in s3.buckets.all():
#     print(bucket.name)

iam = boto3.client('iam')


# response = iam.create_user(
#     UserName = 'Valaxy-Demo-User'
# )

# print(response)

# print(response)

# paginator = iam.get_paginator('list_users')
# for response in paginator.paginate():
#     print(response)

iam.delete_user(
    UserName='Valaxy-Demo-User'
)