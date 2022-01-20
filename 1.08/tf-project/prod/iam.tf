
resource "aws_iam_instance_profile" "server_profile" {
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name_prefix         = var.environment
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role" "bastion_role" {
  name_prefix         = var.environment
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "cloud_watch_write_metrics" {
  name        = "CloudWatchWriteMetrics"
  description = "Write Metrics to CLoudWatch"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricData",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloud_watch_write_metrics_server" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.cloud_watch_write_metrics.arn
}

resource "aws_iam_role_policy_attachment" "cloud_watch_write_metrics_bastion" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.cloud_watch_write_metrics.arn
}