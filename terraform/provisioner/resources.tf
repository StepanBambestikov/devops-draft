data "digitalocean_ssh_key" "rebrain_key" {
  name = var.rebrain_key_name
}

resource "digitalocean_ssh_key" "my_key" {
  name = var.my_key_name
  #public_key = var.my_ssh_key
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "digitalocean_tag" "email_tag" {
  name = var.email_tag
}

resource "digitalocean_tag" "module_tag" {
  name = var.module_tag
}

locals{
  droplet_ips = digitalocean_droplet.web[*].ipv4_address
  droplet_passwords = random_string.password[*].result
  usernames = [for user in var.devs : split("-", user)[1]]
  prefixes = [for user in var.devs : split("-", user)[0]]
  domain_names = [for count in range(length(local.usernames)) : "${local.prefixes[count]}-${local.usernames[count]}.${var.domain_name}"]
}

resource "random_string" "password"{
  count = length(local.usernames)
  length = var.password_length
  lower = false
}

resource "digitalocean_droplet" "web" {
  count = length(local.usernames)
  image = "ubuntu-20-04-x64"
  name = "web-1"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
  tags = [digitalocean_tag.email_tag.id, digitalocean_tag.module_tag.id]

  provisioner "remote-exec" {

    connection{
      host = digitalocean_droplet.web[count.index].ipv4_address
      type = "ssh"
      user = "root"
      #private_key = var.my_private_key
      private_key = "${file("~/.ssh/id_rsa")}"      
    }    

    inline = [
      "echo 'root:${local.droplet_passwords[count.index]}' | chpasswd",
      "sleep 60s",
      "echo 'ip: ${digitalocean_droplet.web[count.index].ipv4_address}, password: ${local.droplet_passwords[count.index]}'",
      "sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config",
      "sed -i 's/PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sed -i 's/#PubkeyAuthentication .*/PubkeyAuthentication no/g' /etc/ssh/sshd_config",
      "systemctl restart sshd",
    ]
  }
}

data "aws_route53_zone" "domain_zone"{
  name = var.input_domain_zone
}

resource "aws_route53_record" "domain"{
  count = length(local.usernames)
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name = local.domain_names[count.index]
  type = "A"
  ttl = var.ttl_number
  records = [local.droplet_ips[count.index]]
}

resource "local_file" "infra_info"{
  filename = "${path.module}/infra_info.txt"
  content = "${templatefile("${path.root}/vms.tftpl", {domain_names = local.domain_names, droplet_ips = local.droplet_ips, droplet_passwords = local.droplet_passwords})}"
}
