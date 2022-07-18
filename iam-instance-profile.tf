resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ProjectName}-${var.env}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.ProjectName}-${var.env}-ec2-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.ProjectName}-${var.env}-ec2-policy"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
    name = "${var.ProjectName}-${var.env}-ec2-policy-attachment"
    roles = [
        aws_iam_role.ec2_role.name,
    ]
    policy_arn = aws_iam_policy.ec2_policy.arn
}