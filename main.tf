data "aws_vpc" "targetVpc" {
  filter {
    name   = "tag:Name"
    values = ["MGMT-VPC"]
  }
}

data "aws_subnet" "endpointSubnet1" {
  vpc_id = data.aws_vpc.targetVpc.id
  filter {
    name   = "tag:Name"
    values = ["MGMT-Private-A"]
  }
}

data "aws_subnet" "endpointSubnet2" {
  vpc_id = data.aws_vpc.targetVpc.id
  filter {
    name   = "tag:Name"
    values = ["MGMT-Private-B"]
  }
}

data "aws_subnet" "endpointSubnet3" {
  vpc_id = data.aws_vpc.targetVpc.id
  filter {
    name   = "tag:Name"
    values = ["MGMT-Private-C"]
  }
}

data "aws_security_groups" "vpc_sg" {
  tags = {
    Name        = "MGMT-VPC-Traffic-SG"
    Environment = "MGMT"
  }
}

data "aws_route_table" "public" {
  tags = {
    Name        = "MGMT-Public-Route-Table"
    Environment = "MGMT"
  }
}

data "aws_route_table" "private" {
  tags = {
    Name        = "MGMT-Private-Route-Table"
    Environment = "MGMT"
  }
}

module "interface_endpoints" {
  source = "./modules/endpoints"
  interface_endpoints = {
    "com.amazonaws.eu-west-2.ec2" = {
      phz = "ec2.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.rds" = {
      phz = "rds.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.sqs" = {
      phz = "sqs.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.sns" = {
      phz = "sns.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.ssm" = {
      phz = "ssm.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.logs" = {
      phz = "logs.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.ssmmessages" = {
      phz = "ssmmessages.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.ec2messages" = {
      phz = "ec2messages.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.s3" = {
      phz = "s3.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.autoscaling" = {
      phz = "autoscaling.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.ecs" = {
      phz = "ecs.eu-west-2.amazonaws.com"
    }
    "com.amazonaws.eu-west-2.athena" = {
      phz = "athena.eu-west-2.amazonaws.com"
    }
  }
  gateway_endpoints = {
    "com.amazonaws.eu-west-2.s3" = {
      route_table_ids = ["${data.aws_route_table.private.route_table_id}", "${data.aws_route_table.public.route_table_id}"]
    }
  }
  vpc_id     = data.aws_vpc.targetVpc.id
  subnet_ids = ["${data.aws_subnet.endpointSubnet1.id}", "${data.aws_subnet.endpointSubnet2.id}", "${data.aws_subnet.endpointSubnet3.id}"]
}
