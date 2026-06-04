# Find the latest official Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
# --- EC2 INSTANCES ---

# 1. Public Web Server
resource "aws_instance" "web_server" {
  # resource = tells Terraform to create and manage a specific infrastructure object
  # "aws_instance" = exact resource type, in this case, means an EC2
  # "web_server" = local logical name
  # in java, it would look like:
  # Resource aws_instance = new aws_instance(web_server)
   ami = data.aws_ami.ubuntu.id # Ubuntu 22.04 LTS
  # ami is Amazon Machine Image -> basically, provides a template of an OS 
  #using the above line and the first code block of finding the lastest version of Ubuntu, this makes it so I dont have to hunt down the exact string of charecters if im using a diff. region or version update
  instance_type = "t2.micro"
  #definint how much storage the instance will have  
  subnet_id = aws_subnet.public.id
  # tells u which subnet to put the ec2 in
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  # vpc_security_group_ids: Attaches a virtual virtual firewall to the instance, 
  # references security group block (in [])
  # 

  tags = {
    Name = "public-web-server"
  }
}

# 2. Private Application Server
resource "aws_instance" "app_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
   # Reusing the security group for testing, dont do this in production enviro

  tags = {
    Name = "private-app-server"
  }
}