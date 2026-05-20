provider "aws" {
  region = var.region
}

resource "aws_vpc" "iii" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "iii-vpc" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.iii.id
  cidr_block = "10.0.1.0/24"
  tags = { Name = "iii-private-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.iii.id
  tags = { Name = "iii-igw" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.iii.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "iii-route-table" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "main" {
  name   = "iii-main-sg"
  vpc_id = aws_vpc.iii.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3111
    to_port   = 3111
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "main" {
  ami                    = "ami-0c02fb55956d7c4c2"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.main.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl git nodejs npm nginx python3-pip supervisor
              
              curl -fsSL https://iii.dev/install.sh | bash
              export PATH=$PATH:/root/.iii/bin
              
              git clone https://github.com/Alchemyst-ai/hiring /opt/hiring
              cd /opt/hiring/may-2026/devops/quickstart
              
              pip3 install transformers torch --break-system-packages
              
              iii --config config.yaml --host 0.0.0.0 &
              iii worker add ./workers/inference-worker --config config.yaml &
              
              cat > /etc/nginx/sites-available/default << 'NGINX'
              server {
                  listen 80;
                  location / {
                      proxy_pass http://localhost:3111;
                      proxy_set_header Host \$host;
                  }
              }
              NGINX
              ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
              nginx -t && service nginx restart
              EOF

  tags = { Name = "iii-main" }
}

output "instance_public_ip" {
  value = aws_instance.main.public_ip
}