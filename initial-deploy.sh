#!/bin/bash -e

# Only run this script once during initial bootstrapping
# You will see a "Backend configuration changed" error notification if you re-run

cp resources/main-local-backend.tf main.tf

terraform init

terraform apply --auto-approve

BUCKET_NAME=$(terraform output -raw aws_s3_bucket)

printf "BUCKET_NAME = $BUCKET_NAME\n"

cp resources/main-remote-backend.tf main.tf

sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

terraform init -force-copy