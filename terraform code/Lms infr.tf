# Terraform code for the provision of infrastructure for LMS App on AWS

provider "aws" {
    region_name = "us-east-1"

}

# VPC
Resource "aws_vpc" "main" {
    cidr_block         = 10.0.0.0/16
    enable_dns_support = true
    enable_dns_support = true
    tags = {
        Name = "lms-vpc"
    }
}

# Public Subnet
Resource "aws_public_subnet" "public" {
    vpc_id                  = aws_vpc.main.vpc_id
    cidr_block              = 10.0.1.0/24
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"
    tags = {
        Name = "lms-public-subnet"
    }
}

# Private Subnet
Resource "aws_private_subnet" "private" {
    vpc_id             = aws_vpc.main.id
    cidr_block         = 10.0.2.0/24
    availability_zone  = "us-east-1b"
    tags = {
        Name = "lms-private-subnet"
    }
}

# Internet Gateway
Resource "aws_internet_gateway" "IG" {
    vpc_id     = aws_vpc.main.id
    tags = {
        Name = "lms-IG"
    }
}

# Public Route Table
Resource "aws_public_route" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = 0.0.0.0/0
        gateway_id = aws_internet_gateway.IG.id
    }
    tags = {
        Name = "lms-public-rt"
    }
}
Resource "aws_rt_association" "public_rt" {
    subnet_id = aws_public_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Private Route Table 
Resource "aws_private_route" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "lms-private-rt"
    }
}

Resource "aws_rt_association" "private_rt" {
    subnet_id = aws_private_subnet.private.id
    route_table_id = aws_private_route.private.id
}

# Security Group
Resource "aws_security_group" "web_sg" {
    name        = "lms-web-sg"
  description = "Allow HTTP/HTTPS and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lms-security-group"
  }
}

# EC2 Instance

resource "aws_instance" "lms_web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your region's latest Amazon Linux AMI
  instance_type = "t2.large"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "LMS-Web-Server"
  }
}








