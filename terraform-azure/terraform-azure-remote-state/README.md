# Azure Remote State Module

This module provisions a new Azure Storage Account to store Terraform state remotely to allow colloboration between the development team.

**This is a one-off exercise that must applied ahead of all other resources in the configuration.**

1. Navigate to the terraform-azure-remote-state directory using your CLI 
2. Run the command `terraform init`, then `terraform apply` to configure the Azure storage account and container
3. Use Azure CLI to retrieve the access key and store this in the corresponding environment variable

        ACCOUNT_KEY=$(az storage account keys list --resource-group 's187d01-eyrecovery-tfstate-rg' --account-name <storage account name> --query '[0].value' -o tsv)
        export ARM_ACCESS_KEY=$ACCOUNT_KEY

4. Now configure the backend for the remote state in the terraform.tf file in the root terraform-azure directory using the values generated in this module
5. Initialise the root terraform-azure module with `terraform-init`

ref. https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=terraform
