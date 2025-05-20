pipeline {
    agent {
        docker {
            image 'my-jenkins-with-docker:latest'
            // Start with this, add --group-add if needed
            args '-v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        IMAGE_NAME = 'my-html-site'
        APP_PORT = 8082
    }

    stages {
        stage('Prepare Environment') { // This will run inside the new agent
            steps {
                script {
                    echo "Verifying Docker client installation and connection to daemon..."
                    sh 'docker --version'
                    sh 'docker info'
                }
            }
        }

        stage('Clone Repo') { // SCM checkout is handled by Jenkins into the agent workspace
            steps {
                echo 'Cloning repository into agent workspace...'
                checkout scm // This is the standard way
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
