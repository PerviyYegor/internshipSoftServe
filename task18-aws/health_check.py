import boto3
import botocore
from botocore.errorfactory import ClientError
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)
bucketEnvVarName = "S3_BUCKET_NAME"

#console_handler = logging.StreamHandler()
#console_handler.setLevel(logging.INFO)
#logger.addHandler(console_handler)

def successfulExecution(result_holder):
    result_holder['statusCode'] = 200
    result_holder['body'] = json.dumps('Health check executed successfully!')

def unsuccessfulExecution(result_holder, err):
    result_holder['body'] = json.dumps(f'Health check executed unsuccessfully! You got error: {err}')

def lambda_handler(event, context):
    result_holder = {'statusCode': None, 'body': None}
    logger.info("Started to execute lambda function to check health check")
    client = boto3.client('ec2')
    response = client.describe_instance_status()
    instance_statuses = response.get('InstanceStatuses', [])
    result_array = []

    for instance_status in instance_statuses:
        instance_id = instance_status.get('InstanceId')
        instance_tag = client.describe_tags(Filters=[{'Name': 'resource-id','Values': [instance_id,],}, ],).get("Tags", [{}])[0].get("Value")

        state_name = instance_status.get('InstanceState', {}).get('Name')
        status = instance_status.get('InstanceStatus', {}).get('Status')
        instance_json = {
            "InstanceId": instance_id,
            "InstanceTag": instance_tag,
            "InstanceState": state_name,
            "Status": status
        }
        result_array.append(json.dumps(instance_json))
    logger.info(f"Got this information about available ec2's in this aws account: {result_array}")

    ## Send output to S3
    s3 = boto3.client('s3')
    bucket_name = os.environ.get(bucketEnvVarName)

    if bucket_name != None:
        logger.info(f"Send info about ec2's to: {bucket_name}")
        key = 'health_check_output.json'
        try:
            s3.put_object(Body=json.dumps(result_array), Bucket=bucket_name, Key=key)
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "404":
                logger.error(f"Did not find bucket with name {bucket_name}. Create bucket and try again")
                unsuccessfulExecution(result_holder, f"Did not find bucket with name {bucket_name}")
    else: 
        logger.error(f"Did not find any bucket name in environment variable. Create \"{bucketEnvVarName}\" environment variable with bucket name and try execute lambda again")
        unsuccessfulExecution(result_holder, "Did not find any bucket name in environment variable")
    
    if result_holder['statusCode'] == 200:
        logger.info(f"To get current ec2's state in your aws-cli you can execute this command: aws s3 cp s3://{bucket_name}/{key} -")
    return result_holder

#if __name__ == "__main__":
#    result = lambda_handler(None, None)
#    print(result)
