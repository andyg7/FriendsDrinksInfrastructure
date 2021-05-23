#!/bin/zsh

set -e

password=$1
user=AdminUser

output=$(aws iam update-login-profile --user-name $user --password "$password")
echo "$output"
