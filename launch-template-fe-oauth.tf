data "aws_ssm_parameter" "ecs-optimized" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}


## FE-OAUTH LAUNCH TEMPLATE ##
resource "aws_launch_template" "ecs-cicd-launch-template-fe-oauth" {
  name          = "ecs-launch-template-fe-oauth"
  image_id      = "ami-0d5c43a84ffd669fe"
  instance_type = "t3.micro"
  key_name      = "ecs-cicd-project"

  #user_data = filebase64("${path.module}/user_data.sh")
  user_data = base64encode(<<EOF
#!/bin/bash
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-fe-oauth.name} >> /etc/ecs/ecs.config
  EOF
  )

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  ebs_optimized = true

  instance_market_options {
    market_type = "spot"
  }


  iam_instance_profile {
    arn = "arn:aws:iam::015594108990:instance-profile/ecs-cicd-project-role"
  }


  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.sg_allow_all.id]
}
