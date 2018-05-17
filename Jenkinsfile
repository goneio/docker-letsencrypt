pipeline {
    agent any
    stages {
        stage('Prepare') {
            steps {
                sh 'make prepare'
            }
        }
        stage('Build') {
            steps {
                 sh 'make build'
            }
        }
        stage('Push') {
            steps {
                sh 'make push'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}