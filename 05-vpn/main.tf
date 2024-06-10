resource "aws_key_pair" "vpn" {
  key_name   = "vpn"
  # you can paste the public key directly like this (If folder path error)
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhue7/kpjytBYg+knidffbACyrQSxj3SHQngYXLRX/e Admin@ManikantaReddy"
  
  public_key = file("C:/devops/.ssh/openvpn.pub") #  ssh -i /c/devops/.ssh/openvpn openvpnas@44.200.211.226 (Password: Abcd@1234)
  # ~ means windows home directory
}
#Admin username: openvpn
#Password: Abcd@1234
module "vpn" { # Below is creating EC2 Instance (By using AMI) and taking above KEY 
  source  = "terraform-aws-modules/ec2-instance/aws"
  key_name = aws_key_pair.vpn.key_name
  name = "${var.project_name}-${var.environment}-vpn"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  
  # Converting StringList to list and get first element (In terraform considers StringList as String only? Bcz--> contains with commas)
  subnet_id = local.public_subnet_id # Giving SG ID created for bastion (Keeping in Public Subnet)
  ami = data.aws_ami.ami_info.id # Getting  AMI ID From data source
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

# Here it uses open vpn AMI and takes the key and creates KEY --> Then we can login