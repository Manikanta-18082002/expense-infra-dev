#Creating 1 Bastion Instance

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-bastion"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  
  # Converting StringList to list and get first element (In terraform considers StringList as String only? Bcz--> contains with commas)
  subnet_id = local.public_subnet_id # Giving SG ID created for bastion (Keeping in Public Subnet)
  ami = data.aws_ami.ami_info.id # Getting  AMI ID From data source
  user_data = file("bastion.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}