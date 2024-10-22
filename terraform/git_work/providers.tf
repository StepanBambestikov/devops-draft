terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.20.0"
    }
  }
  required_version = ">= 0.13"
}

provider "gitlab" {
  token = var.my_token
  base_url = var.repo_url
}

