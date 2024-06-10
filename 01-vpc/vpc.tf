# Our Module is Ready to use that & just paste below
#In big projects will maintain Seperate repos, BUT here we are dividing in seperate folders in same repo

module "vpc" {
    #source = "../terraform-aws-vpc" # Taking source from local
    source = "git::https://github.com/Manikanta-18082002/terraform-aws-vpc.git?ref=main" #Reference from main Branch
    project_name = var.project_name
    common_tags = var.common_tags    
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs
    is_peering_required = var.is_peering_required
}