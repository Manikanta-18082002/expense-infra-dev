data "aws_ssm_parameter" "db_sg_id" {
  name = "/${var.project_name}/${var.environment}/db_sg_id"
}

data "aws_ssm_parameter" "db_subnet_group_name" {
  #depends_on = [aws_ssm_parameter.db_subnet_group_name]  # From GPT
  name = "/${var.project_name}/${var.environment}/db_subnet_group_name"
}