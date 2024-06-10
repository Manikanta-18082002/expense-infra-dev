variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
    Component = "app-alb"
  }
}

variable "zone_name" {
  default = "dawsmani.site"
}

variable "zone_id" {
  default = "Z0518893283P6UJCL06B2"
} # Individual Zone ID's