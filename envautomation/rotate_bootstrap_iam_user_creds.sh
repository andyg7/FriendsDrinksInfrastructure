#!/usr/bin/env bash

set -eu

aws iam list-access-keys --user-name BootstrapUser

echo 'Delete returned access keys manually'

new_access_key=$(aws iam create-access-key --user-name BootstrapUser | jq -r '.AccessKey')
echo "New access key $new_access_key"

aws secretsmanager --region us-east-1 update-secret --secret-id BootstrapUserCredentials --secret-string "$new_access_key"

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