import os
import boto3

# s3 = boto3.resource('s3')

# for bucket in s3.buckets.all():
#     print(bucket.name, bucket.creation_date)

# s3 = boto3.client('s3')
# response = s3.list_buckets()

# print('Existing buckets and objects')
# bucketname = []
# for bucket in response['Buckets']:
#     bucketname.append(bucket["Name"])
# for bucket in bucketname:
#     response = s3.list_objects_v2(Bucket=bucket)
#     print(bucket, 'has objects:' , [content['Key'] + ' size: ' + str(content['Size']) for content in response['Contents']])


# iam = boto3.client('iam')


# response = iam.create_user(
#     UserName = 'Valaxy-Demo-User'
# )

# print(response)

# print(response)

# paginator = iam.get_paginator('list_users')
# for response in paginator.paginate():
#     print(response)

# iam.delete_user(
#     UserName='Valaxy-Demo-User'
# )


s3 = boto3.resource('s3')

# s3.Bucket(name=bucket).objects.all()

for bucket in s3.buckets.all():
    for object in bucket.objects.all():
        print(bucket.name, object.key, object.size)
