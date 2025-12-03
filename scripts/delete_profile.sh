ROLE="S3-SSM-CW-Role"
PROFILE="S3-SSM-CW-Profile"
aws iam remove-role-from-instance-profile \
    --instance-profile-name "$PROFILE" \
    --role-name "$ROLE"
aws iam delete-instance-profile \
    --instance-profile-name "$PROFILE"
aws iam list-attached-role-policies --role-name "$ROLE"
ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE" --query 'AttachedPolicies[].PolicyArn' --output text)
for POLICY_ARN in $ATTACHED_POLICIES; do
    echo "Detaching managed policy $POLICY_ARN from role $ROLE"
    aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$POLICY_ARN"
done
aws iam delete-role --role-name "$ROLE"

# aws iam list-role-policies --role-name "$ROLE"
# POLICIES=$(aws iam list-role-policies --role-name "$ROLE" --query 'PolicyNames' --output text)
# for POLICY in $POLICIES; do
#     echo "Deleting inline policy $POLICY from role $ROLE"
#     aws iam delete-role-policy --role-name "$ROLE" --policy-name "$POLICY"
# done