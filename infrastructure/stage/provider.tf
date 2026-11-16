# AWS
provider "aws" {
  region = "eu-west-1"
  alias  = "dns"
  assume_role {
    role_arn     = "arn:aws:iam::728230171110:role/TerraformRole"
    session_name = "Terraform"
  }
}

provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn     = "arn:aws:iam::235637425445:role/TerraformRole"
    session_name = "Terraform"
  }
}

# Terraform cloud
variable "terraform_workspace_id" {
  type        = string
  default     = "glovo-talk-2022-event-based-autoscaling-stage"
  description = "TF Cloud workspace"
}

data "aws_eks_cluster" "target" {
  name = "services-dev-1"
}

data "aws_eks_cluster_auth" "target" {
  name = data.aws_eks_cluster.target.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.target.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.target.token
  }
}

terraform {
  backend "remote" {
    organization = "glovo"

    workspaces {
      name = "glovo-talk-2022-event-based-autoscaling-stage"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
