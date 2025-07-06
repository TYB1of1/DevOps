// Jenkinsfile
// -----------------------------------
pipeline {
    agent {
        docker {
            image 'my-jenkins-with-docker:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        IMAGE_NAME = 'my-html-site'
        APP_PORT = 8082
    }

    stages {
        stage('Verify Docker') {
            steps {
                echo 'Checking Docker CLI...'
                sh 'docker --version'
                sh 'docker info'
            }
        }

        stage('Clone Repo') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${env.IMAGE_NAME}..."
                    sh """
                        docker build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} .
                        docker tag ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.IMAGE_NAME}:latest
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
