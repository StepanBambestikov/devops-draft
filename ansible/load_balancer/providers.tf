terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "aws"{
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key 
}


