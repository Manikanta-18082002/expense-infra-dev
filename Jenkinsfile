pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds() // No Multiple  Builds
        ansiColor('xterm')
    }
    parameters {
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Pick something')
    }
    stages {
        stage('Init') { // init should happen regardless of apply or destroy
            steps { // Below we are writing scripts
               sh """ 
                cd 01-vpc
                terraform init -reconfigure
               """
            }
        }
        stage('Plan') {
            when {
                expression{ // --? refering the vaiables (like if)
                    params.action == 'Apply'
                }
            }
            steps {
                sh """
                cd 01-vpc
                terraform plan
                """
            }
        }
        stage('Deploy') {
            when {
                expression{
                    params.action == 'Apply'
                }
            }
            input {
                message "Should we continue?"
                ok "Yes, we should." // yes button will pop-up, user need to press
            }
            steps {
                sh """
                cd 01-vpc
                terraform apply -auto-approve
                """
            }
        }

        stage('Destroy') {
            when {
                expression{
                    params.action == 'Destroy'
                }
            }
            steps {
                sh """
                cd 01-vpc
                terraform destroy -auto-approve
                """
            }
        }

    }

    post {  //This will catch the event and send Alerts to Mail/Slack
        always { 
            echo 'I will always say Hello again!'
            deleteDir() // After Building  Workspace need to delete else (Some problems changes will not reflect)
            // Above (Check path in AGENT node) --> jenkins-agent/workspace/Expense (NO VPC Folder)
        }
        success { 
            echo 'I will run when pipeline is success'
        }
        failure { 
            echo 'I will run when pipeline is failure'
        }
    }
}