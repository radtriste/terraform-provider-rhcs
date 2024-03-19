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
  aws_region = "us-west-2"
  cluster_name = "tr-tf-72486"
}

provider "aws" {
  region  = local.aws_region
  profile = "saml"
}

locals {
  account_role_path = "/"
  account_role_prefix = "tr-tf"
  operator_role_prefix = "tr-tf-72486"

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
  }

  aws_subnet_ids     = ["subnet-094212284052e93ca", "subnet-09f0bdcb176f1ff09"]
  availability_zones = ["us-west-2a"]

  sts                = local.sts_roles

  kms_key_arn = "arn:aws:kms:us-west-2:301721915996:key/5adcab9a-f87b-4746-95c9-6d6bf0eb51f6"
}

output "id" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
}

output "name" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.name
}