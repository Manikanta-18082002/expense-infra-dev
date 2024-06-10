resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"  #Output: /expense/dev/vpc_id
  type  = "String" # Capital S (AWS Notation)
  value = module.vpc.vpc_id # To get vpc_id (We need to expose in outputs --> terraform-aws-vpc)
}
# List format: ["id1", "id2"] --> Terraform Format
# AWS SSM Parameter formate    -->  id1 , id2 (String List)

# Convert List --> String List
# EX:  join(", ", ["foo", "bar", "baz"]) #Output: foo, bar, baz

resource "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
  type = "StringList"
  value = join("," , module.vpc.public_subnet_ids) # Converting List to StringList
  
}
resource "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/private_subnet_ids"
  type = "StringList"
  value = join(",",module.vpc.private_subnet_ids)  # Converting List to StringList
  
}
resource "aws_ssm_parameter" "db_subnet_group_name" {
  name  = "/${var.project_name}/${var.environment}/db_subnet_group_name"
  type  = "String"
  value = module.vpc.database_subnet_group_name
}

# SSM:  provides secure, hierarchical storage for configuration data management and secrets management.
# --> Why we need SSM (Systems Manager) -> AWS --> Parameter Store --> Create

# Use:
# We have 01_VPC, 02_SG to get data from 1 -> Like VPC_ID, Subnet_ID Store in SSM