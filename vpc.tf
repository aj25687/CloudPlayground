# Public Subnet (e.g., for Load Balancers, Bastion hosts)
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true # Automatically assigns public IPs to instances here

  tags = {
    Name = "public-subnet-1a"
  }
}

# Private Subnet (e.g., for Databases, Application servers)
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1a"
  }
}