locals {
  common_tags = {
    Environment     = var.env
    Project         = var.ProjectName
    ManagedBy       = var.ManagedBy
  }
}