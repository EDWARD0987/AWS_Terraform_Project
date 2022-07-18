resource "aws_instance" "app_server_ec2" {
  ami                    = var.app_server_ami_id
  instance_type          = var.app_server_instance_type
  subnet_id              = aws_subnet.private_subnet-01.id
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  private_ip             = var.ec2-app-ip 
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = "40"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }

  volume_tags = merge(
    local.common_tags,
    {
      "Name" = "${var.env}-app-server-disk",
    },
  )

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.env}-app-server",
    },
  )

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}