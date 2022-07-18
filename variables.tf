variable "ProjectName" {
  description = "Name of the project"
}

variable "env" {
  description = "Environment"
}

variable "ManagedBy" {
  description = "Who is managing this project"
}

variable "main_region" {
  description = "Main region"
}

variable "origin" {
  description = "S3 Origin Name"
}

variable "app_server_ami_id" {
  description = "App Server AMI ID"
}

variable "app_server_instance_type" {
  description = "App Server Instance Type"
}

variable "ec2-app-ip" {
  description = "App Server IP"
}

variable "elb-account-id" {
  description = "ELB Account ID"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
}

variable "public_subnet-01_cidr" {
  description = "Public Subnet 01 CIDR"
}

variable "public_subnet-01_az" {
  description = "Public Subnet 01 AZ"
}

variable "public_subnet-02_cidr" {
  description = "Public Subnet 02 CIDR"
}

variable "public_subnet-02_az" {
  description = "Public Subnet 02 AZ"
}

variable "private_subnet-01_cidr" {
  description = "Private Subnet 01 CIDR"
}

variable "private_subnet-01_az" {
  description = "Private Subnet 01 AZ"
}

variable "private_subnet-02_cidr" {
  description = "Private Subnet 02 CIDR"
}

variable "private_subnet-02_az" {
  description = "Private Subnet 02 AZ"
}