#!/bin/zsh

set -e

aws iam create-user --user-name CloudFormationDeployerUser
access_key=$(mktemp)
echo "$access_key"
aws iam create-access-key --user-name CloudFormationDeployerUser | jq -r '.AccessKey' > "$access_key"

cat $access_key

export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' "$access_key")
export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' "$access_key")

rm -rf $access_key

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
