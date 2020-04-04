resource "aws_security_group" "base" {
  name        = "base"
  description = "all access needs from my apex apartment"

  dynamic "ingress" {
    for_each = [22, 8000, 8089]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
        "73.78.216.54/32",
        "73.229.170.110/32"
      ]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
