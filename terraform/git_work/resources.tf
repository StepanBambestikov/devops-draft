
data "gitlab_group" "devops_users_repos"{
  full_path = var.group_name
}

resource "gitlab_project" "ter_project" {
  name = "ter00001"
  description = "first3 terraform project"
  namespace_id = "${data.gitlab_group.devops_users_repos.id}"
}

resource "gitlab_deploy_key" "my_deploy_key" {
  project = gitlab_project.ter_project.id
  title = "Terraform Deploy Key"
  key = var.deploy_key
  can_push = true
}

