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
  config  = yamldecode(templatefile(var.config_file, local.context))
}


###################################################
# Providers
###################################################
provider "aws" {
  region  = local.context.region
}
