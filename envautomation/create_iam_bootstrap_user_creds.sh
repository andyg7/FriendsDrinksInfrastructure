#!/bin/zsh

set -eu


export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
region=$3

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

aws secretsmanager --region $region create-secret --name BootstrapUserCredentials --secret-string "{\"AWS_ACCESS_KEY_ID\": \"$AWS_ACCESS_KEY_ID\", \"AWS_SECRET_ACCESS_KEY\":\"$AWS_SECRET_ACCESS_KEY\"}"

travis encrypt AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
travis encrypt AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
