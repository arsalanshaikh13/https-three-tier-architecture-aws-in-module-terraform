#!/bin/bash
set -eo pipefail

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

cd ../root

DIRECTORY="application-code"

if [ -d "$DIRECTORY" ]; then
  echo "Directory '$DIRECTORY' exists."
else
  echo "Directory '$DIRECTORY' does not exist."
  git clone https://github.com/pandacloud1/AWS_Project1.git application-code
fi

source env.sh

terraform init -reconfigure
terraform fmt
terraform validate
# terraform plan -out=graph/plan2.out -refresh=false
# terraform show -json graph/plan2.out > graph/plan2.json
terraform apply -auto-approve -parallelism=20 -refresh=false
terraform graph > graph/graph2.txt


# terraform destroy -target=module.nat_instance

# ./startup.sh 2>&1 | tee >(sed 's/\x1b\[[0-9;]*m//g' > setup-logs/setupnew.log )
