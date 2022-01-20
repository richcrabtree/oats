output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.server_profile.arn
}