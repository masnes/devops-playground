resource "aws_instance" "log_server" {
  ami           = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type = "t3a.micro"
  key_name      = aws_key_pair.t480_laptop.key_name

  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [
    aws_security_group.base.id,
    aws_security_group.intraconnected.id
  ]

  root_block_device {
    encrypted = true
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/masnes/.ssh/id_rsa")
  }

}

resource "aws_eip" "log_server_ip" {
  instance = aws_instance.log_server.id
}

resource "aws_route53_record" "log_server" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "log-server.devops-playground.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.log_server_ip.private_ip]
}

output "log_server" {
  value = aws_instance.log_server.public_dns
}
