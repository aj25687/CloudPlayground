# --- DYNAMIC AMI LOOKUP ---

# Automatically searches AWS for the newest official Ubuntu 22.04 LTS image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- EC2 INSTANCES ---

# 1. Public Web Server (Hosting your OpenRouter AI Wrapper App)
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  # The automation script updated for OpenRouter
  user_data = <<-EOF
              #!/bin/bash
              # 1. Update system packages and install Python tools
              apt-get update -y
              apt-get install python3-pip python3-venv -y

              # 2. Navigate to the default ubuntu user space and make an app folder
              cd /home/ubuntu
              mkdir ai-wrapper
              cd ai-wrapper

              # 3. Create a python virtual environment and install Streamlit & Requests
              python3 -m venv venv
              source venv/bin/activate
              pip install streamlit requests

              # 4. Write the Python code for the OpenRouter wrapper website
              cat << 'PYTHON' > app.py
              import streamlit as st
              import requests

              st.title("🤖 My OpenRouter AI Wrapper")
              st.write("Enter a prompt below to get a response from a free LLaMA 3 model via OpenRouter.")

              user_prompt = st.text_input("Your Prompt:", placeholder="Type something here...")

              if st.button("Ask AI"):
                  if user_prompt:
                      st.info("Thinking...")
                      
                      # UPDATED: OpenRouter Endpoint
                      api_url = "https://openrouter.ai/api/v1/chat/completions"
                      
                      # Put your OpenRouter key right here
                      api_key = "8274f8e44e22090be4a5d8f58f0695cd88aa2da57d65af621dd0261bf391c91e" 
                      
                      headers = {
                          "Authorization": f"Bearer {api_key}",
                          "Content-Type": "application/json",
                          # OpenRouter likes these optional headers to show what app is calling it
                          "HTTP-Referer": "http://localhost", 
                          "X-Title": "Avantika Local Test App"
                      }
                      
                      payload = {
                          # UPDATED: Using a highly capable free model from OpenRouter
                          "model": "meta-llama/llama-3-8b-instruct:free",
                          "messages": [{"role": "user", "content": user_prompt}]
                      }
                      
                      try:
                          response = requests.post(api_url, json=payload, headers=headers)
                          
                          if response.status_code == 200:
                              result = response.json()
                              ai_answer = result["choices"][0]["message"]["content"]
                              st.success("### AI Response:")
                              st.write(ai_answer)
                          else:
                              st.error(f"API Error! Status Code: {response.status_code}")
                              st.json(response.json())
                              
                      except Exception as e:
                          st.error(f"An unexpected error occurred: {e}")
                  else:
                      st.warning("Please enter a prompt first!")
              PYTHON

              # 5. Change ownership of files so the system doesn't lock them
              chown -R ubuntu:ubuntu /home/ubuntu/ai-wrapper

              # 6. Start the Streamlit application on Web Port 80 in the background
              nohup venv/bin/streamlit run app.py --server.port 80 --server.address 0.0.0.0 > streamlit.log 2>&1 &
              EOF

  tags = {
    Name = "public-web-server"
  }
}

# 2. Private Application Server (Kept empty/isolated for future use)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_web.id] 

  tags = {
    Name = "private-app-server"
  }
}