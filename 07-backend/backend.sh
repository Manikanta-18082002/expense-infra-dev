#!/bin/bash
component=$1 # From main.t line 42 (sud0 )
environment=$2
dnf install ansible -y
pip3.9 install botocore boto3 # To connect to AWS
ansible-pull -i localhost, -U https://github.com/Manikanta-18082002/expense-ansible-roles-tf.git main.yaml -e component=$component -e env=$environment
# Component is Backend,  pulling code from git hub and running main.yaml file then backend will be ready
 # -i localhost: we are externally passing inventory which is localhost




# remote provisoner
# ---------------------
# execute the scripts in remote servers
# ansible-playbook -i <inventory> <yaml-name> -e var=value --> ansible server

# ansible pull
# --------------
# install ansible in remote node
# ansible-pull -i <inventory> <ansible-playbook-git-url> <yaml-name> -e var=value --> remote node