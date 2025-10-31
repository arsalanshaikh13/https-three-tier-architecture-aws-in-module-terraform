#!/bin/bash
set -eo pipefail

# git clone https://github.com/pandacloud1/AWS_Project1.git application-code

# setup terraform state bucket
cd backend-tfstate-bootstrap
DIRECTORY_BACKEND=".terraform"

if [ -d "$DIRECTORY_BACKEND" ] ; then
  echo "Directory '$DIRECTORY_BACKEND' exists."
  if grep -q '"resources": \[\]' terraform.tfstate; then
    echo "tfstate does not contains resources."
    terraform init -reconfigure -upgrade
    terraform fmt
    terraform validate
    terraform apply -auto-approve -parallelism=20 -refresh=false
  fi
  echo "tfstate does  contain resources."

else
  echo "Directory '$DIRECTORY_BACKEND' does not exist."
  echo "Setting up Terraform state bucket and DyanmoDB Table"

  terraform init -reconfigure
  terraform fmt
  terraform validate
  terraform apply -auto-approve -parallelism=20 -refresh=false
fi
# exit 1

cd ../root
# cd root

DIRECTORY="application-code"

if [ -d "$DIRECTORY" ]; then
  echo "Directory '$DIRECTORY' exists."
else
  echo "Directory '$DIRECTORY' does not exist."
  git clone https://github.com/pandacloud1/AWS_Project1.git application-code
#   sed -i \
#   -e "s/DB_HOST : ''/DB_HOST : \"\${db_host}\"/" \
#   -e "s/DB_USER : ''/DB_USER : \"\${db_username}\"/" \
#   -e "s/DB_PWD : ''/DB_PWD : \"\${db_password}\"/" \
#   -e "s/DB_DATABASE : ''/DB_DATABASE : \"\${db_name}\"/" \
#   application-code/application-code/DbConfig.js
fi
# Create S3 bucket and dynamodb for Terraform state if it doesn't exist
# echo "Setting up Terraform state bucket"
# AWS_REGION="us-east-1"
# BUCKET_NAME="panda-backend"
# if ! aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
#     echo "Creating S3 bucket for Terraform state..."
#     if [ "$AWS_REGION" = "us-east-1" ]; then
#         # us-east-1 doesn't support LocationConstraint
#         aws s3api create-bucket \
#             --bucket $BUCKET_NAME \
#             --region $AWS_REGION
#     else
#         aws s3api create-bucket \
#             --bucket $BUCKET_NAME \
#             --region $AWS_REGION \
#             --create-bucket-configuration LocationConstraint=$AWS_REGION
#     fi
#     aws s3api put-bucket-versioning \
#         --bucket $BUCKET_NAME \
#         --versioning-configuration Status=Enabled
# else
#     echo "s3 bucket '$BUCKET_NAME' exists."
# fi

# echo "Setting up Terraform state DyanmoDB Table"
# # Create  dynamodb for Terraform state if it doesn't exist
# TABLE_NAME="panda-lock-table"
# if aws dynamodb describe-table --table-name $TABLE_NAME > /dev/null 2>&1; then
#     echo "Table '$TABLE_NAME' exists."
# else
#     echo "Table '$TABLE_NAME' does not exist."
#     echo "Creating dynamodb table for Terraform state..."
#     aws dynamodb create-table \
#         --table-name $TABLE_NAME \
#         --attribute-definitions AttributeName=LockID,AttributeType=S \
#         --key-schema AttributeName=LockID,KeyType=HASH \
#         --billing-mode PAY_PER_REQUEST

# fi

source env.sh

terraform init -reconfigure
terraform fmt
terraform validate
terraform plan -out=graph/plan2.out -refresh=false
terraform show -json graph/plan2.out > graph/plan2.json
terraform apply -auto-approve -parallelism=20 -refresh=false
terraform graph > graph/graph2.txt


# terraform destroy -target=module.nat_instance

# ./startup.sh 2>&1 | tee >(sed 's/\x1b\[[0-9;]*m//g' > setup-logs/setupnew.log )