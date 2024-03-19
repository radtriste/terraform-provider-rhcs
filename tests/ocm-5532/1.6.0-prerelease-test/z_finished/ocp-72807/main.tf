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
  cluster_name = "tr-tf-72807"
}

provider "aws" {
  region  = local.aws_region
  profile = "saml"
}

locals {
  account_role_path = "/"
  account_role_prefix = "tr-tf"
  operator_role_prefix = "tr-tf-72807"

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

locals {
  iamRoles = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  tags     = { red-hat = true }
}

resource "aws_kms_key" "cluster_kms_key" {
  description             = "BYOK Test Key for API automation"
  tags                    = { red-hat = true }
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "cluster_kms_key_policy" {
  key_id = aws_kms_key.cluster_kms_key.id
  policy = jsonencode({
    # Id = var.kms_name
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = local.iamRoles
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
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

  etcd_encryption = true
  etcd_kms_key_arn = aws_kms_key.cluster_kms_key.arn
  kms_key_arn = aws_kms_key.cluster_kms_key.arn
}

output "id" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
}

output "name" {
  value = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.name
}