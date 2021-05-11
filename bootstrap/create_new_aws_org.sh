#!/bin/zsh

set -eu

ORG_NAME='FriendsDrinksOrganization'
PARENT_ID=$1

ORG_ID=$(aws organizations create-organizational-unit --name $ORG_NAME --parent-id "$PARENT_ID" \
--query 'OrganizationalUnit.[Id]' \
--output text)

echo $ORG_ID
