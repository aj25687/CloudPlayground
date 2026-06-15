# --- AMI LOOKUP ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- DEFAULT VPC LOOKUP ---
data "aws_vpc" "default" {
  default = true
}

# --- CUSTOM SECURITY GROUP ---
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-playground-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "web-server-sg"
  }
}

# --- EC2 INSTANCE ---
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id 
  instance_type          = "t3.micro"
  
  # REMOVED KEY_NAME TO FIX THE 400 INVALIDKEYPAIR ERROR
  
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Force system updates
              sudo apt-get update -y
              sudo apt-get install -y python3 python3-stdlib

              # Create app path
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app

              # Clean string replacement injected flawlessly via Terraform's interpreter
              cat << 'HTML' > index.html
              ${replace(file("${path.module}/index.html"), "__OPENROUTER_API_KEY__", var.openrouter_key)}
              HTML

              # Launch server as root
              sudo nohup python3 -m http.server 80 > /dev/null 2>&1 &
              EOF

  tags = {
    Name = "web-server-pg"
  }
}

# --- OUTPUTS ---
output "website_url" {
  description = "The public web address of your live website"
  value       = "http://${aws_instance.web_server.public_ip}"
}

# --- VARIABLES ---
variable "openrouter_key" {
  type        = string
  description = "The secret API key for OpenRouter"
  sensitive   = true
}