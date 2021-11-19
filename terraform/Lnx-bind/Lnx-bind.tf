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


resource "digitalocean_droplet" "www-lnx05" {
  image     = "ubuntu-20-04-x64"
  name      = "www-lnx05"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  tags      = ["nginx", "dmikulich_at_mail_ru", "linux"]
  private_networking = true
  #user_data = file("terramino_app.yaml")
  ssh_keys  = [digitalocean_ssh_key.my.fingerprint]

  provisioner "file" {
    source      = "~/project/terraform/Lnx-bind/bind.sh"
    destination = "/tmp/bind.sh"
    connection {
      type     = "ssh"
      user     = "root"
      host     = "${self.ipv4_address}"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = ["apt update", 
              "chmod +x /tmp/bind.sh",
              "/tmp/bind.sh ${self.ipv4_address}",
              "echo Done!"]
    connection {
      type     = "ssh"
      user     = "root"
      host     = "${self.ipv4_address}"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

output "ip_address" {
  value = digitalocean_droplet.www-lnx05.ipv4_address
  description = "The public IP address of your Droplet application."
}

output "droplet_tags" {
  value = digitalocean_droplet.www-lnx05.tags
}