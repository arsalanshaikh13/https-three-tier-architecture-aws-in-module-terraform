
# Fetch the latest ARM64 Amazon Linux 2023 AMI
data "aws_ami" "latest_amazon_linux" {
    most_recent = true

    filter {
        name   = "name"
        # values = ["al2023-ami-2023.*-arm64"] # Using ARM for cost optimization
        values = [var.ami_type_name] # Using ARM for cost optimization
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"]
}


resource "aws_launch_template" "lt_name" {
  name          = "${var.project_name}-tpl"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.frontend_instance_type
  key_name      = var.client_key_name
  # key_name      = var.key_name
  # user_data     = filebase64("../modules/asg/client.sh")

  user_data = base64encode(templatefile("${path.module}/client_new.sh", {
    internal_alb_dns_name = var.internal_alb_dns_name
    bucket_name = var.bucket_name
    ssh_username = var.ssh_username
  }))
    # backend_alb_dns = var.internal_alb_dns_name


  # vpc_security_group_ids = [var.client_sg_id]

   network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.client_sg_id]
  }
  iam_instance_profile {
    # name = var.s3_ssm_instance_profile_name
    name = var.s3_ssm_cw_instance_profile_name
  }

  lifecycle {
    ignore_changes = [image_id]
    create_before_destroy = false
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      # volume_type = "standard"
      volume_type           = var.frontend_volume_type
      delete_on_termination = true
      # volume_size = 8
      volume_size = var.backend_volume_size
      encrypted   = true
    }

  }
  # propagate tag on the instance launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-client"
      Environment = var.environment
    }
  }
  tags = {
    Name = "${var.project_name}-tpl"
    Environment = var.environment
  }
}

resource "aws_launch_template" "server_lt_name" {
  name          = "${var.project_name}-server_tpl"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.backend_instance_type
  key_name      = var.server_key_name
  # key_name      = var.key_name
  # user_data     = filebase64("../modules/asg/server.sh")
  # depends_on = [ aws_s3_object.DbConfig ]

  # vpc_security_group_ids = [var.server_sg_id]

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.server_sg_id]
  }


 user_data = base64encode(templatefile("${path.module}/server_new.sh", {
    db_host     = var.db_dns_address
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
    db_secret_name     = var.db_secret_name
    bucket_name = var.bucket_name
    aws_region = var.region
    ssh_username = var.ssh_username

  }))
  iam_instance_profile {
    # name = var.s3_ssm_instance_profile_name
    name = var.s3_ssm_cw_instance_profile_name
  }

  lifecycle {
    ignore_changes = [image_id]
    create_before_destroy = false
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      # volume_type = "standard"
      volume_type           = var.backend_volume_type
      delete_on_termination = true
      # volume_size = 8
      volume_size = var.backend_volume_size
      encrypted   = true
    }

  }

  # propagate tag on the instance launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-server"
      Environment = var.environment

    }
  }
  tags = {
    Name = "${var.project_name}-server_tpl"
    Environment = var.environment

  }
}

resource "aws_autoscaling_group" "asg_name" {

  name                      = "${var.project_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type #"ELB" or default EC2
  vpc_zone_identifier = [var.pri_sub_3a_id,var.pri_sub_4b_id]
  target_group_arns   = [var.tg_arn] 

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.lt_name.id
    # version = aws_launch_template.lt_name.latest_version 
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value              = "${var.project_name}-client-ec2"
    propagate_at_launch = true
  }

}
resource "aws_autoscaling_group" "server_asg_name" {

  name                      = "${var.project_name}-server-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type #"ELB" or default EC2
  vpc_zone_identifier = [var.pri_sub_5a_id,var.pri_sub_6b_id]
  target_group_arns   = [var.internal_tg_arn] #var.target_group_arns

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.server_lt_name.id
    # version = aws_launch_template.server_lt_name.latest_version 
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value              = "${var.project_name}-server-ec2"
    propagate_at_launch = true
  }

}
