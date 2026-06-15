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

# --- DEFAULT NETWORK LOOKUPS ---
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# --- FIREWALL CONFIGURATION ---
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

# --- EC2 INSTANCE ---
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id 
  instance_type          = "t3.micro"
  key_name               = "webpg" 
  vpc_security_group_ids = [data.aws_security_group.default.id]

  user_data = <<-EOF
              #!/bin/bash
              # 1. Force wait for system locks to clear and update packages
              sudo apt-get update -y

              # 2. Explicitly install Python 3 and its standard library utilities
              sudo apt-get install -y python3 python3-stdlib

              # 3. Create and jump into the application folder
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app

              # 4. Write the frontend layout file
              cat << 'HTML' > index.html
              ${file("${path.module}/index.html")}
              HTML

              # 5. Run Python explicitly as root on port 80 with standard log routing
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