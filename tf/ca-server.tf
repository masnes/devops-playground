resource "aws_instance" "ca_server" {
  ami             = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type   = "t3a.nano"
  key_name        = aws_key_pair.t480_laptop.key_name
  security_groups = [aws_security_group.base.name]

  root_block_device {
    encrypted = true
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

output "ca_server" {
  value = aws_instance.log_server.public_dns
}
