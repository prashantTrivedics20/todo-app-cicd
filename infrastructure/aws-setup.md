# AWS Infrastructure Setup Guide

This guide will help you set up the AWS infrastructure needed to deploy the Todo App.

## Prerequisites

- AWS CLI installed and configured
- Terraform installed (optional, for infrastructure as code)
- SSH key pair for EC2 access

## Manual Setup

### 1. Create EC2 Instance

```bash
# Create security group
aws ec2 create-security-group \
    --group-name todo-app-sg \
    --description "Security group for Todo App"

# Add inbound rules
aws ec2 authorize-security-group-ingress \
    --group-name todo-app-sg \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name todo-app-sg \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name todo-app-sg \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name todo-app-sg \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name todo-app-sg \
    --protocol tcp \
    --port 5000 \
    --cidr 0.0.0.0/0

# Launch EC2 instance
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t3.medium \
    --key-name your-key-pair \
    --security-groups todo-app-sg \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=todo-app-server}]'
```

### 2. Setup EC2 Instance

```bash
# SSH into your instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/todo-app/main/scripts/setup-ec2.sh | bash
```

### 3. Configure GitHub Secrets

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `EC2_HOST`: Your EC2 instance public IP
- `EC2_USER`: EC2 username (usually 'ubuntu')
- `EC2_PRIVATE_KEY`: Your private SSH key content
- `DOCKER_USERNAME`: Docker registry username
- `DOCKER_PASSWORD`: Docker registry password

## Terraform Setup (Recommended)

### 1. Create Terraform Configuration

```hcl
# infrastructure/main.tf
provider "aws" {
  region = var.aws_region
}

# VPC and Networking
resource "aws_vpc" "todo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "todo-app-vpc"
  }
}

resource "aws_internet_gateway" "todo_igw" {
  vpc_id = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo-app-igw"
  }
}

resource "aws_subnet" "todo_public_subnet" {
  vpc_id                  = aws_vpc.todo_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "todo-app-public-subnet"
  }
}

resource "aws_route_table" "todo_public_rt" {
  vpc_id = aws_vpc.todo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todo_igw.id
  }

  tags = {
    Name = "todo-app-public-rt"
  }
}

resource "aws_route_table_association" "todo_public_rta" {
  subnet_id      = aws_subnet.todo_public_subnet.id
  route_table_id = aws_route_table.todo_public_rt.id
}

# Security Group
resource "aws_security_group" "todo_sg" {
  name_prefix = "todo-app-sg"
  vpc_id      = aws_vpc.todo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "todo-app-sg"
  }
}

# EC2 Instance
resource "aws_instance" "todo_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.todo_sg.id]
  subnet_id             = aws_subnet.todo_public_subnet.id

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "todo-app-server"
  }
}

# Elastic IP
resource "aws_eip" "todo_eip" {
  instance = aws_instance.todo_server.id
  domain   = "vpc"

  tags = {
    Name = "todo-app-eip"
  }
}
```

### 2. Variables and Outputs

```hcl
# infrastructure/variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Ubuntu 22.04 LTS
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}
```

```hcl
# infrastructure/outputs.tf
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.todo_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.todo_server.public_dns
}
```

### 3. Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform plan -var="key_name=your-key-pair"
terraform apply -var="key_name=your-key-pair"
```

## Cost Optimization

### Instance Types
- **Development**: t3.micro (Free tier eligible)
- **Production**: t3.medium or t3.large
- **High Traffic**: c5.large or m5.large

### Storage
- Use GP3 EBS volumes for better cost/performance
- Enable EBS optimization
- Set up automated snapshots

### Monitoring
- Enable CloudWatch monitoring
- Set up billing alerts
- Use AWS Cost Explorer

## Security Best Practices

1. **Network Security**
   - Use VPC with private subnets for database
   - Implement security groups with least privilege
   - Enable VPC Flow Logs

2. **Instance Security**
   - Regular security updates
   - Use IAM roles instead of access keys
   - Enable CloudTrail logging

3. **Application Security**
   - Use HTTPS with SSL certificates
   - Implement rate limiting
   - Regular security scanning

## Backup Strategy

1. **Database Backups**
   - Automated daily MongoDB backups
   - Cross-region backup replication
   - Point-in-time recovery

2. **Application Backups**
   - EBS snapshots
   - AMI creation for quick recovery
   - Configuration backup to S3

## Monitoring and Alerting

1. **CloudWatch Metrics**
   - CPU utilization
   - Memory usage
   - Disk space
   - Network traffic

2. **Application Monitoring**
   - Health check endpoints
   - Error rate monitoring
   - Response time tracking

3. **Alerting**
   - SNS notifications
   - Slack integration
   - PagerDuty for critical alerts