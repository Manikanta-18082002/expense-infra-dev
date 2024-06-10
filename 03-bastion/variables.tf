variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev" 
}

variable "common_tags" {
    default = {
        Project = "expnse"
        Environment = "dev"
        Terraform = "true"
    } 
}
