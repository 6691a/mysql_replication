locals {
    vpc = data.terraform_remote_state.local_remote.outputs.vpc
    subnets = data.terraform_remote_state.local_remote.outputs.subnets
    security_group = data.terraform_remote_state.local_remote.outputs.security_group
}

data "terraform_remote_state" "local_remote" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}


