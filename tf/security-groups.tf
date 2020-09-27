variable "allowed_ips" {
  type        = list(string)
  description = "A list of one or more ip addresses (not cidr's) that you will be accessing from."
  default     = ["73.78.216.54"]
}

resource "aws_security_group" "public_servers" {
  name        = "public_servers"
  description = "access to bastions and other public servers"

  vpc_id = aws_vpc.devops_playground.id

  # external access
  dynamic "ingress" {
    for_each = [22, 8000, 8089]
    iterator = port
    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "tcp"
      cidr_blocks = [
        for ip in var.allowed_ips :
        "${ip}/32"
      ]
    }
  }

  # internal access
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private.cidr_block,
    ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_servers" {
  name        = "private_servers"
  description = "security group associated with servers in the private subnet"

  vpc_id = aws_vpc.devops_playground.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.public.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_intraconnected" {
  name        = "private_intraconnected"
  description = "allow things to talk to each other"

  vpc_id = aws_vpc.devops_playground.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.public.cidr_block,
      aws_subnet.private.cidr_block,
    ]
  }
}
