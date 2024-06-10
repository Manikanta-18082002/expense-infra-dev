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
    Component = "app-alb" # Component is useful: to check billing for  (db, app-lb, frontend-lb) how much we getting?
  }
}

variable "zone_name" {
  default = "dawsmani.site"
}