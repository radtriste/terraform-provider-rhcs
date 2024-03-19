terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    rhcs = {
      version = "= 1.6.0-prerelease.2"
      source  = "terraform-redhat/rhcs"
    }
  }
}

# Define RHCS_TOKEN and RHCS_URL instead
# provider "rhcs" {
# }

locals {
  aws_region = "us-east-1"
  cluster_name = "tr-tf-72498"
}

provider "aws" {
  region  = local.aws_region
  profile = "saml"
}

locals {
  account_role_path = "/"
  account_role_prefix = "tr-tf"
  operator_role_prefix = "tr-tf-72498"

  sts_roles = {
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${local.account_role_prefix}-HCP-ROSA-Installer-Role",
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${local.account_role_prefix}-HCP-ROSA-Support-Role",
    instance_iam_roles = {
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${local.account_role_prefix}-HCP-ROSA-Worker-Role"
    }
    operator_role_prefix = local.operator_role_prefix
  }
}

data "aws_caller_identity" "current" {
}

resource "rhcs_cluster_rosa_hcp" "rosa_hcp_cluster" {
  name                   = local.cluster_name
  cloud_region           = local.aws_region
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_billing_account_id = data.aws_caller_identity.current.account_id

  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
    # provision_shard_id = "10746dff-4b03-11ee-b47c-0a580a800afd"
  }

  aws_subnet_ids     = ["subnet-0ee6e26295cca0e77", "subnet-08dc75944ece99e54"]
  availability_zones = ["us-east-1b"]

  sts                = local.sts_roles

  version = "4.13.37"
}

output "id" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
}

output "name" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.name
}