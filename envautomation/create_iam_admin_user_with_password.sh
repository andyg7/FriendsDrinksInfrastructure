#!/bin/zsh

set -eu

PASSWORD=$1
USER_NAME=AdminUser

aws iam create-user --user-name $USER_NAME
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name $USER_NAME

output=$(aws iam create-login-profile --user-name $USER_NAME --password "$PASSWORD")
echo "$output"
