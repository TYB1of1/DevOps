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

        stage('Verify Container') {
            steps {
                sh "docker run --rm ${env.IMAGE_NAME}:latest echo 'Image works!'"
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
