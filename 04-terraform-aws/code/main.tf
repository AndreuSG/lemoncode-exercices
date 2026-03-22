# PROVIDER
provider "aws" {
  region = "eu-west-3"
}

# VPC
resource "aws_vpc" "pac_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "pac-vpc"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pac_vpc.id

  tags = {
    Name = "pac-igw"
  }
}

# SUBNET
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.pac_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pac-public-subnet"
  }
}

# ROUTE TABLE
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.pac_vpc.id

  tags = {
    Name = "pac-public-rt"
  }
}

# ROUTE TO INTERNET
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ASSOCIATION SUBNET TO ROUTE TABLE
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# SECURITY GROUP FOR WEB SERVERS
resource "aws_security_group" "web_sg" {
  name   = "pac-web-sg"
  vpc_id = aws_vpc.pac_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from my IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["37.222.48.71/32"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pac-web-sg"
  }
}

# KEY PAIR
resource "aws_key_pair" "pac_key" {
	key_name   = "pac-ec2-key"
	public_key = file("~/.ssh/pac_ec2_key.pub")
}

# EC2 IMAGE
data "aws_ami" "amazon_linux_2" {
	most_recent = true
	owners      = ["amazon"]

	filter {
		name   = "name"
		values = ["amzn2-ami-hvm-*-x86_64-gp2"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}
}

# EC2 INSTANCE
resource "aws_instance" "web_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.pac_key.key_name
  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "pac-web-instance"
  }
}

# OUTPUT PUBLIC IP OF THE WEB INSTANCE
output "web_instance_public_ip" {
	value = aws_instance.web_instance.public_ip
}