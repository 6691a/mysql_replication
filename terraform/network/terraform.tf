###################################################
# Terrafrom
###################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.35.0"
    }
  }
}

###################################################
# Local Variables
###################################################
locals {
  context = yamldecode(file(var.config_file)).context
  all  = yamldecode(templatefile(var.config_file, local.context))
  vpc  = local.all.vpc
  subnet_group = local.all.subnet_group

}


###################################################
# Providers
###################################################
provider "aws" {
  region  = local.context.region
}
