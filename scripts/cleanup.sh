#!/bin/bash
set -euo pipefail

# echo "🧹 Starting Terraform cleanup process..."
# # Folders that should be destroyed in parallel
# sequential_destroy_one=(
#   "terraform/hosting/route53"
#   "terraform/hosting/cloudfront"  
# )
#   # "terraform/compute/asg"
#   # "terraform/compute/alb" 
#   # "terraform/nat_key/nat_instance" 

# echo "🔥 Destroying selected Terraform stacks in sequence..."

# # ---- PARALLEL BLOCK ----
# for dir in "${sequential_destroy_one[@]}"; do
#   echo "🚀 Starting destroy in background: $dir"

#   TG_PROVIDER_CACHE=1 terragrunt run \
#     --non-interactive \
#     --working-dir "$dir" \
#     -- destroy -auto-approve --parallelism 20 
#     # -- destroy -auto-approve --parallelism 20 || true 

# done

# echo "⏳ Waiting for sequential tasks to complete..."
# wait
# echo "✅ sequential destroy completed."

# parallel_destroy_one=(
#   "terraform/hosting/cloudfront"  
#   "terraform/compute/asg"
# )

# echo "🔥 Destroying selected Terraform stacks in parallel..."

# # # ---- PARALLEL BLOCK ----
# for dir in "${parallel_destroy_one[@]}"; do
#   echo "🚀 Starting destroy in background: $dir"

#   TG_PROVIDER_CACHE=1 terragrunt run \
#     --non-interactive \
#     --working-dir "$dir" \
#     -- destroy -auto-approve --parallelism 20  &
#     # -- destroy -auto-approve --parallelism 20 || true &

# done

# echo "⏳ Waiting for parallel tasks to complete..."
# wait
# echo "✅ Parallel destroy completed."

# # ---- SEQUENTIAL BLOCK ----
# # compute folders destroyed in order (sequential)
# sequential_destroy_two=(
#   "terraform/compute/alb" 
#   "terraform/nat_key/nat_instance" 
# )

# echo "🔥 Destroying compute stacks sequentially..."

# for dir in "${sequential_destroy_two[@]}"; do
#   echo "🧨 Destroying $dir..."
  
#   TG_PROVIDER_CACHE=1 terragrunt run \
#     --non-interactive \
#     --working-dir "$dir" \
#     -- destroy -auto-approve --parallelism 20 || true
# done


# echo "⏳ Waiting for sequential tasks to complete..."
# wait
# echo "✅ sequential destroy completed."

parallel_destroy_two=(
  "terraform/database/ssm_prm"
  "terraform/database/rds"
  "terraform/nat_key/key" 
  "terraform/permissions/acm"
  "terraform/permissions/iam_role"
  "terraform/s3"
)
  # "terraform/nat_key/nat" 
  # "terraform/database/aws_secret"

echo "🔥 Destroying selected Terraform stacks in parallel..."

# ---- PARALLEL BLOCK ----
for dir in "${parallel_destroy_two[@]}"; do
  echo "🚀 Starting destroy in background: $dir"

  TG_PROVIDER_CACHE=1 terragrunt run \
    --non-interactive \
    --working-dir "$dir" \
    -- destroy -auto-approve --parallelism 20  &
    # -- destroy -auto-approve --parallelism 20 || true &

done



echo "⏳ Waiting for parallel destroy two tasks to complete..."
wait
echo "✅ parallel destroy two completed."

sequential_destroy_three=(
  "terraform/network/security-group" 
  "terraform/network/vpc"
)

# ---- SEQUENTIAL BLOCK ----
echo "🔥 Destroying remaining stacks sequentially..."

for dir in "${sequential_destroy_three[@]}"; do
  echo "🧨 Destroying $dir..."
  
  TG_PROVIDER_CACHE=1 terragrunt run \
    --non-interactive \
    --working-dir "$dir" \
    -- destroy -auto-approve --parallelism 20 
    # -- destroy -auto-approve --parallelism 20 || true
done


echo "🎉 All stacks destroyed successfully!"

echo "🎉 destroying  tfstate backend s3 and dynamodb table!"

  TG_PROVIDER_CACHE=1 terragrunt run \
    --non-interactive \
    --working-dir backend-tfstate-bootstrap \
    -- destroy -auto-approve --parallelism 20 || true

echo "🎉 tfstate backend s3 and dynamodb table destroyed successfully  from s3!"

# echo "removing terragrunt cache directories..."
find . -type d -name ".terragrunt-cache" -prune -print -exec rm -rf {} \;
find . -type f -name ".terraform.lock.hcl" -prune -print -exec rm -f {} \;
echo "✅ terragrunt cache directories removed."
