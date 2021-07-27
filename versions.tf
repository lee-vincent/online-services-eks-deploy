terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.51.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }

  required_version = ">= 1.0.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "vinnielee-io"

    workspaces {
      name = "online-services-eks-deploy"
    }
  }
}
