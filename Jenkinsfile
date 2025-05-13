pipeline {
    agent any // Ensure Docker is installed and usable on the agent

    environment {
        DOCKER_IMAGE_NAME = 'my-html-site'
        // Use build number for versioning, or 'latest'
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER ?: 'latest'}"
        CONTAINER_NAME = 'portfolio-site-container'
        HOST_PORT = 8080
        CONTAINER_PORT = 80
    }

    stages {
        // Stage 'Clone Repo' is removed assuming "Pipeline script from SCM" is used.
        // Jenkins will automatically check out the code.
        // If you need to force a specific branch or have other SCM needs, use:
        // stage('Checkout') {
        //     steps {
        //         checkout scm // Uses SCM configured in the Jenkins job
        //         // OR for explicit checkout:
        //         // git branch: 'master', url: 'https://github.com/TYB1of1/DevOps.git'
        //     }
        // }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    // The second argument '.' specifies the build context (current directory)
                    docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}", '.')
                }
            }
        }

        stage('Deploy Docker Container') { // Renamed for clarity
            steps {
                script {
                    def fullImageName = "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    echo "Attempting to deploy image: ${fullImageName}"

                    // Stop and remove existing container if it's running
                    // Using sh for more control over error handling (|| true)
                    echo "Stopping existing container named ${CONTAINER_NAME} (if any)..."
                    sh "docker stop ${CONTAINER_NAME} || true"
                    echo "Removing existing container named ${CONTAINER_NAME} (if any)..."
                    sh "docker rm ${CONTAINER_NAME} || true"

                    echo "Running new container ${CONTAINER_NAME} from image ${fullImageName}..."
                    // Use --name to assign a specific name to the container
                    // Map host port to container port
                    docker.image(fullImageName).run("--name ${CONTAINER_NAME} -d -p ${HOST_PORT}:${CONTAINER_PORT}")

                    echo "Portfolio site should be accessible at http://<jenkins_agent_ip>:${HOST_PORT}"
                    echo "You can check running containers with: docker ps"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
            // Example: List docker images for diagnostics
            // sh "docker images ${DOCKER_IMAGE_NAME}"
        }
        success {
            echo "Pipeline executed successfully. Container ${CONTAINER_NAME} should be running."
        }
        failure {
            echo "Pipeline failed. Check console output for errors."
            // Example: Show Docker logs if a container tried to start and failed
            // sh "docker logs ${CONTAINER_NAME} || true"
        }
    }
}
