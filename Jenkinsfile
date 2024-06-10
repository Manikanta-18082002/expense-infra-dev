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
        stage('Init') { // init should happen whether apply or destroy
            steps {
                sh """
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }
        }
        stage('Plan') { // No plan for destory
        when{
            expression{
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
            when{
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
           when{
            expression{
                params.action == 'Destory'
            }
            steps {
                sh """
                    cd 01-vpc
                    terraform destory -auto-approve
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