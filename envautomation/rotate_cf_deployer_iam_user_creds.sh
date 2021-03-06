#!/usr/bin/env bash

set -eu

region=$1

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

aws secretsmanager --region $region update-secret --secret-id CloudFormationDeployerUserCredentials --secret-string "$new_access_key"

export AWS_ACCESS_KEY_ID=$(echo $new_access_key | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $new_access_key | jq -r '.SecretAccessKey')
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

if [ -z "$AWS_ACCESS_KEY_ID" ]
then
      echo "\$AWS_ACCESS_KEY_ID is not set"
      exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
      echo "\$AWS_SECRET_ACCESS_KEY is empty"
      exit 1
fi
