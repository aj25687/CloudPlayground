resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Inbound HTTP and all outbound"
  vpc_id      = aws_vpc.main.id

  # Inbound HTTP rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound "allow everything" rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-web-sg"
  }
}