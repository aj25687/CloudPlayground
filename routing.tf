# Internet Gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw] # Ensures correct creation order
}

# NAT Gateway for the private subnet (placed inside the public subnet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "main-nat-gateway"
  }
}

# --- PUBLIC ROUTING ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route all non-local traffic (0.0.0.0/0) to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Explicitly bind the Public Subnet to the Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# --- PRIVATE ROUTING ---

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route all non-local traffic (0.0.0.0/0) to the NAT Gateway
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Explicitly bind the Private Subnet to the Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}