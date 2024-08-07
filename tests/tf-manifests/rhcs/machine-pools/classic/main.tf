terraform {
  required_providers {
    rhcs = {
      version = ">= 1.1.0"
      source  = "terraform.local/local/rhcs"
    }
  }
}

provider "rhcs" {
}

resource "rhcs_machine_pool" "mps" {
  count                             = var.mp_count
  cluster                           = var.cluster
  machine_type                      = var.machine_type
  name                              = var.mp_count == 1 ? var.name : "${var.name}-${count.index}"
  replicas                          = var.replicas
  labels                            = var.labels
  taints                            = var.taints
  min_replicas                      = var.min_replicas
  max_replicas                      = var.max_replicas
  autoscaling_enabled               = var.autoscaling_enabled
  availability_zone                 = var.availability_zone
  subnet_id                         = var.subnet_id
  multi_availability_zone           = var.multi_availability_zone
  disk_size                         = var.disk_size
  aws_additional_security_group_ids = var.additional_security_groups
  aws_tags                          = var.tags
}
