# Bootstrap

This folder creates the AWS Organizations foundation and remote state resources.

Required actions:
1. Create the management account
2. Enable AWS Organizations
3. Create OUs
4. Create member accounts
5. Create the Terraform state bucket
6. Create the DynamoDB lock table
7. Grant access to required accounts
8. Run the root Terraform stacks

## Important

This directory should only be executed from the management account.
