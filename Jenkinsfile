pipeline {
    agent any // Ensure Docker is installed and usable on the agent

    environment {
        DOCKER_IMAGE_NAME = 'my-html-site' // Name of Docker image
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER ?: 'latest'}" // Tag with build number or 'latest'
        CONTAINER_NAME = 'portfolio-site-container' // Name of running container
        HOST_PORT = 8080 // Port on host
        CONTAINER_PORT = 80 // Port inside container
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone your HTML/CSS repo
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
                    echo "Running basic HTML validation tests..."
                    try {
                        // This 'test' could be more advanced — for now, same as lint
                        sh "docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} htmlhint ."
                        echo "HTML tests passed successfully!"
                    } catch (Exception e) {
                        echo "HTML tests found issues: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                        echo "Marking build as UNSTABLE due to HTML test failures"
                    }
                }
            }
        }

        stage('Code Quality') {
            steps {
                script {
                    echo "Running code quality checks (HTML lint)..."
                    try {
                        sh "docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} htmlhint ."
                        echo "HTML linting passed successfully!"
                    } catch (Exception e) {
                        echo "HTML linting found issues: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                        echo "Marking build as UNSTABLE due to linting issues"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def fullImageName = "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    echo "Deploying Docker container: ${fullImageName}"

                    // Stop and remove any existing container with the same name
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"

                    // Run the container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${fullImageName}"

                    echo "Site should be accessible at http://<jenkins_agent_ip>:${HOST_PORT}"
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
            echo "Pipeline completed with test or lint issues."
        }
    }
}
