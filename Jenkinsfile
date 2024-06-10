pipeline {
    agent {
        label 'AGENT-1'
    }
     options{
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds() // No Multiple  Builds
        ansiColor('xterm')
    }
     parameters {
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Pick something')
    }
    stages {
        stage('Init') {
            steps {
                sh """
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }
        }
        stage('Plan') {
            steps {
                sh """
                    cd 01-vpc
                    terraform plan
                """
            }
        }
        stage('Deploy') {
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
    }
    post{ //This will catch the event and send Alerts to Mail/Slack
        always{
            echo 'Always say hello Again'
            deleteDir()
        }
        success{
            echo 'I will run when pipelin is SUCCESS'
        }
        failure{
            echo 'I will run when pipeline is Failure'
        }
    }
}