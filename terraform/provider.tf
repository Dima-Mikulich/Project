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

resource "digitalocean_ssh_key" "my" {
  name       = "My ssh_keys"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "www-lnx01" {
  image     = "ubuntu-20-04-x64"
  name      = "www-lnx01"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  tags      = ["nginx", "dmikulich_at_mail_ru", "linux"]
  private_networking = true
  #user_data = file("terramino_app.yaml")
  ssh_keys  = [digitalocean_ssh_key.my.fingerprint]

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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.ipv4_address},' -e '{ 'server_hostname': ${self.ipv4_address} }' ~/project/ansible/apache/Lnx04.yml"
    
  }

}

output "ip_address" {
  value = digitalocean_droplet.www-lnx01.ipv4_address
  description = "The public IP address of your Droplet application."
}

output "droplet_tags" {
  value = digitalocean_droplet.www-lnx01.tags
}