#!/bin/zsh

set -eu

region=$1

aws iam create-user --user-name CloudFormationDeployerUser
new_access_key=$(aws iam create-access-key --user-name CloudFormationDeployerUser | jq -r '.AccessKey')
echo "New access key $new_access_key"


aws secretsmanager --region $region create-secret --name CloudFormationDeployerUserCredentials --secret-string "$new_access_key"

AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' "$new_access_key")
AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' "$new_access_key")

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

travis encrypt AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
travis encrypt AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
