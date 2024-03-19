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

provider "aws" {
  region  = var.aws_region
  profile = "saml"
}

locals {
  account_role_path = coalesce(var.path, "/")

  sts_roles = {
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${var.account_role_prefix}-HCP-ROSA-Installer-Role",
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${var.account_role_prefix}-HCP-ROSA-Support-Role",
    instance_iam_roles = {
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.account_role_path}${var.account_role_prefix}-HCP-ROSA-Worker-Role"
    }
    operator_role_prefix = var.operator_role_prefix
  }
}

data "aws_caller_identity" "current" {
}

resource "rhcs_cluster_rosa_hcp" "rosa_hcp_cluster" {
  name                   = var.cluster_name
  cloud_region           = var.aws_region
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_billing_account_id = data.aws_caller_identity.current.account_id

  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }

  aws_subnet_ids     = var.aws_subnet_ids
  availability_zones = var.aws_availability_zones

  sts                = local.sts_roles

  compute_machine_type = var.compute_machine_type
}
