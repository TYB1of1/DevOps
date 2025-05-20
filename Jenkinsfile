pipeline {
    agent {
        docker {
            image 'my-jenkins-with-docker:latest'
            // Add the jenkins user in the agent to GID 0 (root)
            // This matches the GID of the Docker socket in Docker Desktop
            args '-v /var/run/docker.sock:/var/run/docker.sock --group-add 0'
            reuseNode true // Runs on the Jenkins controller, which already has the socket mounted
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
                    sh 'id' // Check user and groups
                    sh 'ls -l /var/run/docker.sock' // Check socket permissions
                    sh 'docker --version'
                    sh 'docker ps' // Simple test for Docker daemon access
                    sh 'docker info' // More comprehensive test
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
        // ... etc. ...
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
