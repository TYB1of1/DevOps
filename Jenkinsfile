pipeline {
    agent any // Ensure Docker is installed and usable on the agent

    environment {
        DOCKER_IMAGE_NAME = 'my-html-site' // Docker image name
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER ?: 'latest'}" // Use build number or 'latest'
        CONTAINER_NAME = 'portfolio-site-container' // Name for the running container
        HOST_PORT = 8080 // Host port to expose
        CONTAINER_PORT = 80 // Container port to map
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout source code from the specified Git repo
                git 'https://github.com/TYB1of1/DevOps.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}", '.')
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Running tests inside Docker container..."
                    sh "docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} pytest tests/ --cov=src --cov-report=term-missing"
                }
            }
        }

        stage('Code Quality') {
            steps {
                script {
                    echo "Running code quality checks inside Docker container..."
                    try {
                        sh "docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} flake8 src/"
                        sh "docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} pylint src/"
                        echo "Code quality checks passed successfully!"
                    } catch (Exception e) {
                        echo "Code quality checks found issues: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                        echo "Marking build as UNSTABLE due to code quality issues"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def fullImageName = "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    echo "Deploying Docker container from image: ${fullImageName}"

                    // Stop and remove any existing container with the same name
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"

                    // Run the new container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${fullImageName}"

                    echo "Deployment complete. Site should be accessible at http://<jenkins_agent_ip>:${HOST_PORT}"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline executed successfully. Container ${CONTAINER_NAME} should be running."
        }
        failure {
            echo "Pipeline failed. Check console output for errors."
        }
        unstable {
            echo "Pipeline completed with code quality issues."
        }
    }
}
