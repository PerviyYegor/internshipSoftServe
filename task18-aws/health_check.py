import datetime
import boto3
import json



def lambda_handler(event, context):
    # Your health check logic here
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
    print(result_array)

    ## Send output to S3
    s3 = boto3.client('s3')
    bucket_name = 'status-check-bucket'
    key = 'health_check_output.json'
    s3.put_object(Body=json.dumps(result_array), Bucket=bucket_name, Key=key)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Health check executed successfully!')
    }


if __name__ == "__main__":
    lambda_handler(None, None)