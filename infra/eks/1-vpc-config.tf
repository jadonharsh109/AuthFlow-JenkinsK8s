# Module for creating a Virtual Private Cloud (VPC) in AWS
module "vpc" {
  # Source for the VPC module from Terraform Registry
  source = "terraform-aws-modules/vpc/aws"

  # Specify the version of the VPC module
  version = "5.5.1"

  # General Settings
  # ----------------
  # Name of the VPC
  name = "authflow_vpc"

  # CIDR block for the VPC
  # This defines the IP range for the entire VPC
  cidr = "10.0.0.0/16"

  # Subnet Configuration
  # ---------------------
  # List of Availability Zones to deploy subnets
  azs = var.azs

  # CIDR blocks for private subnets
  # These subnets will not be directly accessible from the internet
  private_subnets = var.private_subnets

  # CIDR blocks for public subnets
  # These subnets will have internet-facing access
  public_subnets = var.public_subnets

  # NAT Gateway Configuration
  # --------------------------
  # Enable NAT Gateway to allow private subnets to access the internet
  enable_nat_gateway = true

  # Use a single NAT Gateway for all private subnets
  single_nat_gateway = true

  # Use one NAT Gateway per Availability Zone (overrides single NAT Gateway setting)
  one_nat_gateway_per_az = false

  # DNS Configuration
  # ------------------
  # Enable DNS hostnames for instances in the VPC
  enable_dns_hostnames = true

  # Enable DNS support in the VPC
  enable_dns_support = true

  # Tags
  # ----
  # Apply common tags to all resources created by this module
  tags = {
    Environment = "Production"
  }
}
