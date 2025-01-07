data "aws_ssm_parameter" "ecs-optimized" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs-cicd-launch-template" {
  name          = "ecs-launch-template"
  image_id      = "ami-0d5c43a84ffd669fe"
  instance_type = "t3.small"
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

resource "aws_iam_instance_profile" "ecs-cicd-instance-profile" {
  name = "ecs-cicd-instance-profile"
  role = aws_iam_role.ecs-cicd-ec2-role.name
}


resource "aws_iam_role" "ecs-cicd-ec2-role" {
  name = "ecs-cicd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs-cicd-ec2-policy" {
  name = "ecs-cicd-ec2-policy"
  role = aws_iam_role.ecs-cicd-ec2-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "ECS",
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
          #"ecs:ListClusters",
          #"ecs:ListContainerInstances",
          #"ecs:ListServices",
          #"ecs:ListTasks",
          #"ecs:ListTaskDefinitions",
          #"ecs:DescribeClusters",
          #"ecs:DescribeContainerInstances",
          #"ecs:DescribeServices",
          #"ecs:DescribeTasks",
          #"ecs:DescribeTaskDefinition",
          #"ecs:RegisterTaskDefinition",
          #"ecs:DeregisterTaskDefinition",
          #"ecs:CreateCluster",
          #"ecs:DeleteCluster",
          #"ecs:CreateService",
          #"ecs:UpdateService",
          #"ecs:DeleteService",
          #"ecs:RunTask",
          #"ecs:StopTask"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "ECR",
        "Effect" : "Allow",
        "Action" : [
          "ecr:*",
          #"ecr:GetAuthorizationToken",
          #"ecr:BatchCheckLayerAvailability",
          #"ecr:GetDownloadUrlForLayer",
          #"ecr:GetRepositoryPolicy",
          #"ecr:DescribeRepositories",
          #"ecr:ListImages",
          #"ecr:DescribeImages",
          #"ecr:BatchGetImage",
          #"ecr:GetLifecyclePolicy",
          #"ecr:GetLifecyclePolicyPreview",
          #"ecr:ListTagsForResource",
          #"ecr:DescribeImageScanFindings",
          #"ecr:InitiateLayerUpload",
          #"ecr:UploadLayerPart",
          #"ecr:CompleteLayerUpload",
          #"ecr:PutImage"
        ],
        "Resource" : "*"
      }
    ]
  })
}



