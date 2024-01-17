import datetime
import boto3
import botocore
from botocore.errorfactory import ClientError
import json
import os
import logging
from io import StringIO

logger = logging.getLogger()
logger.setLevel(logging.INFO)
memory_handler = logging.StreamHandler(StringIO())
logger.addHandler(memory_handler)

bucketEnvVarName = "S3_BUCKET_NAME"
log_key = 'health_check_log.txt'
ec2_check_key = 'health_check_output.json'


#console_handler = logging.StreamHandler()
#console_handler.setLevel(logging.INFO)
#logger.addHandler(console_handler)

def successfulExecution(result_holder):
    result_holder['statusCode'] = 200
    result_holder['body'] = json.dumps('Health check executed successfully!')

def unsuccessfulExecution(result_holder, err, err_code):
    result_holder['statusCode'] = err_code
    result_holder['body'] = json.dumps(f'Health check executed unsuccessfully! You got error: {err_code}: {err}')

def lambda_handler(event, context):
    result_holder = {'statusCode': 200, 'body': None}
    logger.info("Started to execute lambda function to check health check")
    client = boto3.client('ec2')
    cloudwatch = boto3.client('cloudwatch')

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
            "Status": status,
            "DateTime": datetime.datetime.now().isoformat()
        }
        result_array.append(json.dumps(instance_json))
    logger.info(f"Got this information about available ec2's in this aws account: {result_array}")


    status_counts = {}

    for instance_data in result_array:
        instance = json.loads(instance_data)
        
        state = instance['InstanceState']
        
        if state in status_counts:
            status_counts[state] += 1
        else:
            status_counts[state] = 1

    logger.info(f"Got metric to send: {status_counts}")

    ## Send status metric to cloudwatch
    for status, count in status_counts.items():
        cloudwatch.put_metric_data(
            Namespace='CustomLambdaMetrics',
            MetricData=[
                {
                    'MetricName': 'InstanceStatus',
                    'Dimensions': [
                        {
                            'Name': 'Status',
                            'Value': status
                        },
                    ],
                    'Value': count,
                    'Unit': 'Count',
                },
            ]
        )

    ## Send output to S3
    s3 = boto3.client('s3')
    bucket_name = os.environ.get(bucketEnvVarName)

    if bucket_name != None:
        logger.info(f"Send info about ec2's to: {bucket_name}")
        try:
            s3.put_object(Body=json.dumps(result_array), Bucket=bucket_name, Key=ec2_check_key,ACL='public-read')
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] != "":
                logger.error(f"Did not find bucket with name {bucket_name}. Create bucket and try again")
                unsuccessfulExecution(result_holder, f"Did not find bucket with name {bucket_name}", e.response['Error']['Code'])
    else: 
        logger.error(f"Did not find any bucket name in environment variable. Create \"{bucketEnvVarName}\" environment variable with bucket name and try execute lambda again")
        unsuccessfulExecution(result_holder, "Did not find any bucket name in environment variable", 404)
    
    if result_holder['statusCode'] == 200:
        successfulExecution(result_holder)
        #s3.put_object(Body= memory_handler.stream.getvalue(), Bucket=bucket_name, Key=log_key)
        logger.info(f"To get current ec2's state in your aws-cli you can execute this command: aws s3 cp s3://{bucket_name}/{ec2_check_key} -")
        #logger.info(f"Also you can get lambda log with execute this command: aws s3 cp s3://{bucket_name}/{log_key} -")
    
    return result_holder

#if __name__ == "__main__":
#    result = lambda_handler(None, None)
#    print(result)
#