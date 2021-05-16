#!/bin/zsh

set -eu

EMAIL=$1
STAGE=$2
REGION='us-east-1'
ACCOUNT_NAME="FriendsDrinks-$STAGE-$REGION"

echo "Account name is $ACCOUNT_NAME"

if [[ "$STAGE" == "beta" ]]
then
  echo "$STAGE is a valid stage"
elif [[ "$STAGE" == "prod" ]]
then
  echo "$STAGE is a valid stage"
else
  echo "$STAGE is not a valid stage"
  exit 1
fi

REQUEST_ID=$(aws organizations create-account --email "$EMAIL" --account-name "$ACCOUNT_NAME" \
--query 'CreateAccountStatus.[Id]' \
--output text)

echo "Request ID $REQUEST_ID"

echo "Waiting for new account ..."
ORG_STAT=$(aws organizations describe-create-account-status --create-account-request-id $REQUEST_ID \
--query 'CreateAccountStatus.[State]' \
--output text)

while [ $ORG_STAT != "SUCCEEDED" ]
do
  if [ $ORG_STAT = "FAILED" ]
  then
    printf "\nAccount Failed to Create\n"
    exit 1
  fi
  printf "."
  sleep 10
  ORG_STAT=$(aws organizations describe-create-account-status --create-account-request-id $REQUEST_ID \
  --query 'CreateAccountStatus.[State]' \
  --output text)
done

ACCOUNT_ID=$(aws organizations describe-create-account-status --create-account-request-id $REQUEST_ID \
--query 'CreateAccountStatus.[AccountId]' \
--output text)

echo "Successfully created account and its ID is $ACCOUNT_ID"


