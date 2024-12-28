resource "aws_launch_template" "launch-template-ecs" {
  name          = "ecs-launch-template"
  image_id      = "ami-00237a21ff6310ec6"
  instance_type = "t3.small"

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


  #iam_instance_profile {
  #  name = "test"
  #}


  monitoring {
    enabled = true
  }


  #vpc_security_group_ids = ["sg-12345678"]
}