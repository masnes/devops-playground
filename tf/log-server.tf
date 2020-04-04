provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "log_server" {
  ami             = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type   = "t3a.micro"
  key_name        = aws_key_pair.t480_laptop.key_name
  security_groups = [aws_security_group.base.name]

  root_block_device {
    encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 30
    encrypted   = true
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/masnes/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${aws_key_pair.old_laptop_default.public_key}' >> ~/.ssh/authorized_keys",
      "sudo yum -y install vim bash-completion tmux"
    ]
  }
}


output "log_server" {
  value = aws_instance.log_server.public_dns
}
