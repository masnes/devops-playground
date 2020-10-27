resource "aws_iam_role" "vault_dynamodb" {
  name = "vault_dynamodb"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vault_dynamodb" {
  name = "vault_dynamodb"
  role = aws_iam_role.vault_dynamodb.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:ListTables",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:CreateTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": [ "${aws_dynamodb_table.vault.arn}" ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "vault_dynamodb" {
  name = "vault_dynamodb"
  role = aws_iam_role.vault_dynamodb.name
}
resource "aws_dynamodb_table" "vault" {
  name         = "vault"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "Path"
  range_key = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    name = "vault-dynamodb-table"
  }
}

resource "aws_instance" "vault_server" {
  ami           = "ami-087c2c50437d0b80d" # RHEL 8 x86
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.t480_laptop.key_name

  iam_instance_profile = aws_iam_instance_profile.vault_dynamodb.name

  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [
    aws_security_group.private_servers.id,
    aws_security_group.private_intraconnected.id
  ]

  root_block_device {
    encrypted = true
  }

}


resource "aws_route53_record" "vault_server" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "vault-server"
  type    = "A"
  ttl     = 300
  records = [aws_instance.vault_server.private_ip]
}

output "vault_server" {
  value = aws_instance.vault_server.private_ip
}
