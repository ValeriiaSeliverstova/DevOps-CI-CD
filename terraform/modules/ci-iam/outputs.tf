output "role_arn" {
  description = "IAM role ARN attached to the Jenkins agent service account"
  value       = aws_iam_role.this.arn
}
