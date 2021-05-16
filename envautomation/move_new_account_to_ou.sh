#!/bin/zsh

set -eu

ACCOUNT_ID=$1

DEST_OU_NAME='FriendsDrinksOrganization'

printf "Moving new account to OU\n"
ROOT_OU=$(aws organizations list-roots --query 'Roots[0].[Id]' --output text)
# shellcheck disable=SC2086
DEST_OU=$(aws organizations list-organizational-units-for-parent --parent-id $ROOT_OU --query 'OrganizationalUnits[?Name==`'$DEST_OU_NAME'`].[Id]' --output text)

aws organizations move-account --account-id "$ACCOUNT_ID" --source-parent-id "$ROOT_OU" --destination-parent-id "$DEST_OU" > /dev/null 2>&1
if [ $? -ne 0 ]
then
  printf "Moving Account Failed\n"
fi

