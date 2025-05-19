pipeline {
    agent any

    environment {
        IMAGE_NAME = 'my-html-site'
        APP_PORT = 8082
        DOCKER_HOST = 'unix:///var/run/docker.sock'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    // Verify Docker is installed and accessible
                    sh 'docker --version'
                    sh 'docker info'
                }
            }
        }

        stage('Clone Repo') {
            steps {
                echo 'Cloning repository...'
                git url: 'https://github.com/TYB1of1/DevOps.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${env.IMAGE_NAME}..."
                    // Build with proper caching and cleanup
                    sh """
                        docker build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} .
                        docker tag ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Test HTML') {
            steps {
                script {
                    echo 'Validating HTML files...'
                    sh 'docker run --rm -v $(pwd)/portfolio:/mnt dcycle/html-validator:latest /mnt/index.html'
                    echo 'HTML validation passed.'
                }
            }
        }

        stage('Stop Previous Containers') {
            steps {
                script {
                    echo "Stopping existing containers..."
                    sh '''
                        docker ps -q --filter "ancestor=${IMAGE_NAME}" | xargs -r docker stop || true
                        docker ps -aq --filter "ancestor=${IMAGE_NAME}" | xargs -r docker rm || true
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    echo "Running container on port ${env.APP_PORT}..."
                    sh "docker run -d -p ${env.APP_PORT}:80 --name ${env.IMAGE_NAME}-${env.BUILD_NUMBER} ${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    echo "Testing application..."
                    sh """
                        sleep 5
                        curl -sSf http://localhost:${env.APP_PORT} || (echo 'Smoke test failed!' && exit 1)
                    """
                    echo "Application is running successfully!"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
