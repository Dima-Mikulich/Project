terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {}


data "digitalocean_ssh_key" "example" {
  name = "My ssh_keys"
}

resource "digitalocean_droplet" "www-lnx05" {
  image     = "ubuntu-20-04-x64"
  name      = "www-lnx05"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  tags      = ["nginx", "dmikulich_at_mail_ru", "linux"]
  private_networking = true
  #user_data = file("terramino_app.yaml")
  ssh_keys  = [data.digitalocean_ssh_key.example.fingerprint]

provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
    connection {
      type     = "ssh"
      user     = "root"
      host     = "${self.ipv4_address}"
      private_key = file("~/.ssh/id_rsa")
    }
  }

provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.ipv4_address},' -e '{ 'server_hostname': ${self.ipv4_address} }' ~/project/ansible/nginx/Lnx05.yml"
    
  }

}

output "ip_address" {
  value = digitalocean_droplet.www-lnx05.ipv4_address
  description = "The public IP address of your Droplet application."
}

output "droplet_tags" {
  value = digitalocean_droplet.www-lnx05.tags
}