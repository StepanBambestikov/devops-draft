
variable "my_ssh_key"{
	
}

variable "rebrain_ssh_key"{

}

variable "do_token"{

}

variable "ttl_number"{

}
variable "password_length"{

}
variable "domain_name"{

}

variable "input_domain_zone"{

}

variable "email_tag"{}
variable "module_tag"{}

variable "aws_access_key"{
  sensitive = true
}

variable "aws_secret_key"{
  sensitive = true
}

variable "rebrain_key_name"{}
variable "my_key_name"{}
variable "domain_prefix"{}
variable "droplet_count"{}
variable "my_private_key"{}

variable "devs"{
  type = list(string)
  default = ["lb-username", "app1-username", "app2-username"]
}
