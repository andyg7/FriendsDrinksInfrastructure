#!/usr/bin/env bash

set -eu

while true; do
  aws iam list-access-keys --user-name CloudFormationDeployerUser --max-items 1 --query 'AccessKeyMetadata[0].AccessKeyId' --output text
  access_key_id=$(aws iam list-access-keys --user-name CloudFormationDeployerUser --max-items 1 --query 'AccessKeyMetadata[0].AccessKeyId' --output text | grep -v 'None' || true)
  echo "Access key id is $access_key_id - about to delete it"
  if [ -z "$access_key_id" ]
  then
    break
  else
    aws iam update-access-key --user-name CloudFormationDeployerUser --access-key-id "$access_key_id" --status Inactive
    echo "Made $access_key_id inactive"
    aws iam delete-access-key --user-name CloudFormationDeployerUser --access-key-id  $access_key_id
    echo "Deleted $access_key_id"
  fi
done

echo 'Done deleting access keys'

new_access_key=$(aws iam create-access-key --user-name CloudFormationDeployerUser | jq -r '.AccessKey')
echo "New access key $new_access_key"

aws secretsmanager --region us-east-1 update-secret --secret-id CloudFormationDeployerUserCredentials --secret-string "$new_access_key"

# Save creds in semaphore
export AWS_ACCESS_KEY_ID=$(echo $new_access_key | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $new_access_key | jq -r '.SecretAccessKey')
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

travis encrypt AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
travis encrypt AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
