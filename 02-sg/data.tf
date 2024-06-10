data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id" # Fetches values from --> /expnse/dev/vpc_id (SSM Store)
}