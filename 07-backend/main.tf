module "backend" { # 1st) Now EC2- Instance creation
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}" # expense-dev-backend

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value] # convert StringList to list and get first element
  subnet_id = local.private_subnet_id
  ami = data.aws_ami.ami_info.id
  
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    }
  )
}

# Provisioning means: Copy the file and run scripts in that

# There is NO DOWN TIME HERE? --> New server is created -> After getting this into Running state, then  OLD Server Deleted
# Here we are stoping the AMI 

resource "null_resource" "backend" { # 2) Configuring the Instance using Ansible, terraform NULL RESOURCE
    triggers = {
      instance_id = module.backend.id # this will be triggered everytime instance is created
    }
    connection {  # 1st Need to connect to Remote Server
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = module.backend.private_ip # Through VPN Only we can connect to our Private_ip
    }

    provisioner "file" { # This File will be copied there (Copying the script's into instance)
        source      = "${var.common_tags.Component}.sh"
        destination = "/tmp/${var.common_tags.Component}.sh" # Taking files from source and put them in SERVER
    }

    provisioner "remote-exec" { # To run the Above file we use this remote exec
        inline = [
            "chmod +x /tmp/${var.common_tags.Component}.sh", # File: backend.sh (Open in putty to check file is copied?)
            "sudo sh /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component} ${var.environment}"
        ] # Running  .sh file (Given execution permissoins)
    } 
}

resource "aws_ec2_instance_state" "backend" { #3) Stoping the Instance bcz? To take AMI (Can't take running photos)
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [ null_resource.backend ] # Stoping the serever only when null resource provisioning is completed
}

resource "aws_ami_from_instance" "backend" { # 4) Taking AMI
  name               = "${var.project_name}-${var.environment}-${var.common_tags.Component}" # expense-dev-backend
  source_instance_id = module.backend.id
  depends_on = [ aws_ec2_instance_state.backend ] # Taking AMI After stoping the instance
}

# There is NO Terraform RESOURCE to TERMINATE the instance (We use Provisioners as below)
resource "null_resource" "backend_delete" { # 5) Deleting the Instance
    triggers = {
      instance_id = module.backend.id # this will be triggered everytime instance is created
    }

    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "DevOps321"
        host     = module.backend.private_ip
    }

    provisioner "local-exec" { # --> Bcz? AWS Command Line is installed here
        command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
    } 
    depends_on = [ aws_ami_from_instance.backend ] # Delete this Instance after taking AMI
}

resource "aws_lb_target_group" "backend" { # 6) Create target group
  name     = "${var.project_name}-${var.environment}-${var.common_tags.Component}" # expense-dev-backend
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_launch_template" "backend" {  # 7) When Creating Launch Template (--> Updating the Version and keeping it as Latest)
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  update_default_version = true # It sets the latest version to default
# When we get new AMI, then it creates NEW LAUNCH Template, then we need to refresh in ASG (Below)
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
      }
    )
  }
}


resource "aws_autoscaling_group" "backend" {  # 8) Create ASG (Launch Template is the Input for Autoscaling )
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  max_size                  = 5 
  min_size                  = 1 # Start mini with 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.backend.arn]  
  launch_template { # ---> Is the new thing (Before --> launch configuration (OLD))
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  
# Instead of running from first, only this auoscaling need to update 
#--> There will be some terraform target resource: terraform plan -target=aws_autoscaling_group.backend (In Git bash)
 
  instance_refresh { 
    strategy = "Rolling" # --> New Instances will Created & OLD Will be deleted
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"] 
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "backend" { # 9) Create ASG Policy
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}

resource "aws_lb_listener_rule" "backend" { # 10) Add Rule to the Load Balancer Listner
  # Which listner (Need ARN) ? 06-app-alb -> Line 18 --> Need here (Then Put that 06... in AWS SSM Parameter)
  
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 # less number will be first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.zone_name}"]
    }
  }
}