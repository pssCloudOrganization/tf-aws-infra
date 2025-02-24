# tf-aws-infra

## Infrastructure setup using Terraform on AWS

# Prerequisites
- latest version of Terraform.

# Setup Infrastructure
- Run the following commands to set up infrastructure:

`terraform init` initializes a Terraform working directory by downloading and installing the necessary provider plugins based on the configuration files in your project

`terraform plan` previews changes to your infrastructure before applying them
`terraform plan -var-file="[tfvar file name].tfvars"` Use this command if you want to send variables via a tfvars file.

`terraform apply` takes the changes outlined in a previously generated plan and actually executes them on your infrastructure
`terraform apply -var-file="[tfvar file name].tfvars"` Use this command if you want to send variables via a tfvars file.

# Destroy Infrastructure
- Run the following command to destroy infrastructure:

`terraform destroy`

use tf vars where necessary
