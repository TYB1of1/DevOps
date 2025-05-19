pipeline {
    agent any

    environment {
        IMAGE_NAME = 'my-html-site'
        APP_PORT = 8082
        // This is good to have, especially when mounting the Docker socket
        DOCKER_HOST = 'unix:///var/run/docker.sock'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    echo "Verifying Docker client installation and connection to daemon..."
                    sh 'docker --version'
                    sh 'docker info' // Verifies connection to Docker daemon
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
                    // Assumes Dockerfile is in the root of the cloned repository
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
                    // IMPORTANT: This assumes your index.html is inside a 'portfolio' directory
                    // at the root of your repository (e.g., your-repo/portfolio/index.html).
                    // If index.html is at the root of your repository (your-repo/index.html),
                    // change `$(pwd)/portfolio:/mnt` to `$(pwd):/mnt`.
                    // Adjust the path `/mnt/index.html` accordingly if it's nested deeper.
                    sh 'docker run --rm -v "$(pwd)/portfolio":/mnt dcycle/html-validator:latest /mnt/index.html'
                    echo 'HTML validation passed.'
                }
            }
        }

        stage('Stop Previous Containers') {
            steps {
                script {
                    echo "Stopping and removing existing containers based on image: ${env.IMAGE_NAME}..."
                    // Stops and removes any container built from an image with the IMAGE_NAME
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
                    echo "Running container ${env.IMAGE_NAME}:${env.BUILD_NUMBER} on port ${env.APP_PORT}..."
                    sh "docker run -d -p ${env.APP_PORT}:80 --name ${env.IMAGE_NAME}-${env.BUILD_NUMBER} ${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    echo "Performing smoke test on http://localhost:${env.APP_PORT}..."
                    // A more robust smoke test with retries
                    sh """
                        max_attempts=6
                        attempt_num=1
                        sleep_interval=5
                        until curl -sSf http://localhost:${env.APP_PORT}; do
                            if [ \$attempt_num -eq \$max_attempts ]; then
                                echo "Smoke test failed after \$max_attempts attempts."
                                exit 1
                            fi
                            echo "Attempt \$attempt_num/\$max_attempts: Container not ready, retrying in \$sleep_interval seconds..."
                            sleep \$sleep_interval
                            attempt_num=\$((attempt_num+1))
                        done
                    """
                    echo "Application is running successfully!"
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
