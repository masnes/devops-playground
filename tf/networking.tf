resource "aws_vpc" "devops_playground" {
  cidr_block = "172.16.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.devops_playground.id
  cidr_block        = "172.16.0.0/17" # ends at 172.16.127.255
  availability_zone = "us-west-2b"

  map_public_ip_on_launch = false # It's the default, but make explicit here

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.devops_playground.id
  cidr_block        = "172.16.128.0/24" # ends at 172.16.128.255
  availability_zone = "us-west-2b"

  tags = {
    Name = "public"
  }
}

resource "aws_eip" "public_nat_ip" {
  vpc = true
}

resource "aws_internet_gateway" "playground_gateway" {
  vpc_id = aws_vpc.devops_playground.id

  tags = {
    Name = "playground gateway"
  }
}

resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.public_nat_ip.id
  subnet_id     = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.playground_gateway
  ]

  tags = {
    Name = "public nat"
  }
}

resource "aws_route_table" "public_private_table" {
  vpc_id = aws_vpc.devops_playground.id

  # default route for vpc cidr to local is implicitly created

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat.id
  }

  tags = {
    Name = "public private table"
  }

}

resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.devops_playground.id

  # default route for vpc cidr to local is implicitly created

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.playground_gateway.id
  }

  tags = {
    Name = "public table"
  }

}

resource "aws_route_table_association" "public_private_table" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public_private_table.id
}

resource "aws_route_table_association" "public_table" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_table.id
}
