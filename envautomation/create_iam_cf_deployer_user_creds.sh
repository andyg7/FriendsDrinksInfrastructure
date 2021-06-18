#!/bin/zsh

set -eu

region=$1

aws iam create-user --user-name CloudFormationDeployerUser
new_access_key=$(aws iam create-access-key --user-name CloudFormationDeployerUser | jq -r '.AccessKey')
echo "New access key $new_access_key"


aws secretsmanager --region $region create-secret --name CloudFormationDeployerUserCredentials --secret-string "$new_access_key"

AWS_ACCESS_KEY_ID=$(echo $"$new_access_key" | jq -r '.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $"$new_access_key" | jq -r '.SecretAccessKey')

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