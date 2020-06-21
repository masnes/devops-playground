variable "allowed_ips" {
  type        = list(string)
  description = "A list of one or more ip addresses (not cidr's) that you will be accessing from."
  default     = ["73.78.216.54"]
}

resource "aws_security_group" "base" {
  name        = "base"
  description = "all access needs from provided public ips"

  dynamic "ingress" {
    for_each = [22, 8000, 8089]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
        for ip in var.allowed_ips :
        "${ip}/32"
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
