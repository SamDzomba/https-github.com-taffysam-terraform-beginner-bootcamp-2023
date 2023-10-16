


# Terraform Bootcamp Week1 Update

## The Terraform File structure is made up of the following:

  Root
  ├── variables.tf
  ├── outputs.tf
  ├── main.tf
  ├── providers.tf
  ├── terraform.tfvars
  └── README.md


[Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)


## Terraform Cloud Variables
In terraform we can set **environmental** and **terraform** variables
- **Environmental Variables** : set in bash terminal eg AWS_DEFAULT_REGION
- **Terraform variables**  : set in tfvars eg: user_uuid

We can set terraform could variables to be senstive so that there are not shown visbly in UI 


## Loading Terraform Variables
We can use the `-var` flag to set an input variable or ovverride a variable in tfvars file eg. `terraform -var user_id="my-user-id"'


## Var File Flag
NB Homework

## Terraform.tfvars
- default file to load in terrafrom variables in blunk

## auto.tfvars
NB Homework


## Order of Terraform variables
document which terraform variables take precedence

[Terraform Input Values](https://developer.hashicorp.com/terraform/language/values/variables)



'
cloud {
    organization = "Tafadzwa"
    workspaces {
      name = "terra-house-1"
    }
  }
  
  
  
  variable "user_uuid" {
  description = "User UUID"
  type        = string

  validation {
    condition     = length(var.user_uuid) == 36
    error_message = "User UUID must be 36 characters long"
  }

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.user_uuid))
    error_message = "User UUID must be in the format of a UUID (e.g., 123e4567-e89b-12d3-a456-426655440000)"
  }
}


