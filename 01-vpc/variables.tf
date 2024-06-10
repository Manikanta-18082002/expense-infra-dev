# Edit values based on requirement's (Below var is from terraform-vpc-test)
variable "project_name" {
    default = "expense"
  
}
variable "environment" {
    default = "dev"
  
}
variable "common_tags" {  # Declaring the tags here
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
  
}

variable "public_subnet_cidrs" {
    default = ["10.0.1.0/24","10.0.2.0/24"]  #Provide only 2 CIRDS, IF more / less then Error
}

variable "private_subnet_cidrs" {
    default = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
    default = ["10.0.21.0/24","10.0.22.0/24"]
}

variable "is_peering_required" {
    default = true
  
}