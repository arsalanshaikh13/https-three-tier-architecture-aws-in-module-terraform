
# -------- Variables --------
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where the AMI will be built."
}

variable "source_ami" {
  type        = string
  default     = ""
  description = "Base AMI id to use as the source image (set via -var or environment)."
}

variable "instance_type" {
  type    = string
  # default = "t4g.micro"
  default = "t4g.small"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}
variable "s3_ssm_cw_instance_profile_name" {
  type        = string
  default     = ""
  description = "Instance profile for packer for ssm s3 and cw"
}
variable "bucket_name" {
  type        = string
  default     = ""
  description = "s3  bucket name"
}
variable "internal_alb_dns_name" {
  type        = string
  default     = ""
  description = "alb dns to alter "
}


locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# i am already searching for latest amazon ami in build_ami.sh
# data "amazon-ami" "example" {
#   filters = {
#     virtualization-type = "hvm"
#     name                = "al2023-ami-2023.*-arm64"
#     root-device-type    = "ebs"
#   }
#   owners      = ["amazon"]
#   most_recent = true
#   region      = "us-east-1"
# }
# -------- Source (amazon-ebs builder) --------
source "amazon-ebs" "frontend" {
  region                        = var.aws_region
  source_ami                    = var.source_ami
  # source_ami                  = data.amazon-ami.example.id
  instance_type                 = var.instance_type
  vpc_id                        = var.vpc_id
  subnet_id                     = var.subnet_id
  associate_public_ip_address   = true
  temporary_key_pair_name       = "packer-${local.timestamp}"
  ssh_username                  = var.ssh_username
  # ssh_interface                 = "public_ip"
  # ssh_timeout                   = "10m"
  # ssh_handshake_attempts        = 30
  communicator                  = "ssh"
  # ssh_pty                       = true
  # communicator                  = "ssm"
  ssh_interface    = "session_manager"
  iam_instance_profile        = var.s3_ssm_cw_instance_profile_name


  ami_name                      = "three-tier-frontend-${local.timestamp}"
  ami_description               = "Frontend AMI with Nginx and Git and react"
  tags = {
    Name        = "three-tier-frontend"
    Environment = "dev"
    Component   = "frontend"
  }
  
  launch_block_device_mappings {
      device_name = "/dev/xvda"
      encrypted = true
      volume_type = "standard"
      volume_size = 8
      delete_on_termination = true
  }


}

# -------- Build (ties source -> provisioners -> post-processors) --------
build {
  sources = ["source.amazon-ebs.frontend"]

  # provisioner "shell" {
  #   inline = [
  #     "sudo dnf update -y",
  #     "sudo dnf install -y nginx git"
  #   ]
  # }

  # provisioner "file" {
  #   source      = "nginx.conf"
  #   destination = "/tmp/nginx.conf"
  # }

  # provisioner "shell" {
  #   inline = [
  #     "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf"
  #   ]
  # }
  provisioner "file" {
    source      = "client.sh"           # local file (in same dir as packer/terraform)
    destination = "/tmp/client.sh"      # remote path inside EC2
  }

  provisioner "shell" {
    inline = [
      "export bucket_name='${var.bucket_name}'",
      "export internal_alb_dns_name='${var.internal_alb_dns_name}'",
      "echo $internal_alb_dns_name  $bucket_name  ",
      "echo 'Running app-tier setup...'",
      "sudo chmod +x /tmp/client.sh",
      # "sudo bash /tmp/client.sh '${var.bucket_name}' '${var.internal_alb_dns_name}'"
      "sudo bash /tmp/client.sh $bucket_name $internal_alb_dns_name"
    ]
  }
  post-processor "manifest" {
    output = "manifest.json"
  }
}
