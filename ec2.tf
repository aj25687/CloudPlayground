# --- EC2 INSTANCES ---

# 1. Public Web Server
resource "aws_instance" "web_server" {
  ami = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1 (example)
  # ami is Amazon Machine Image -> basically, provides a template of an OS 
  instance_type = "t2.micro"
  
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "public-web-server"
  }
}

# 2. Private Application Server
resource "aws_instance" "app_server" {
  ami = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_web.id] # Reusing the SG for demonstration

  tags = {
    Name = "private-app-server"
  }
}