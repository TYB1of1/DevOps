pipeline {
    agent any  // Uses the default Jenkins agent
    
    environment {
        IMAGE_NAME = "my-app"  // Your Docker image name
        BUILD_NUMBER = "${env.BUILD_NUMBER}"  // Auto-generated build number
    }
    
    stages {
        // Stage 1: Build the Docker image
        stage('Build') {
            agent {
                docker {
                    image 'my-jenkins-with-docker'  // Your custom Docker image
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u root'  // Mounts host Docker socket
                    reuseNode true  // Reuses the same workspace
                }
            }
            steps {
                script {
                    sh '''
                        echo "Building Docker image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                        echo "Image built: ${IMAGE_NAME}:${BUILD_NUMBER}"
                    '''
                }
            }
        }

        // Stage 2: Run tests inside the built image
        stage('Test') {
            agent {
                docker {
                    image 'my-jenkins-with-docker'  // Same custom image
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                        echo "Running tests..."
                        docker run --rm ${IMAGE_NAME}:${BUILD_NUMBER} npm test  # Example test command
                    '''
                }
            }
        }

        // Stage 3: Deploy the image (example: push to registry)
        stage('Deploy') {
            agent {
                docker {
                    image 'my-jenkins-with-docker'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                        echo "Tagging and pushing image..."
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                        # Example: Push to Docker Hub (requires login)
                        # docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}
                        # docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        # docker push ${IMAGE_NAME}:latest
                        echo "Deployment completed (example: image tagged as latest)"
                    '''
                }
            }
        }
    }

    // Post-build actions (cleanup, notifications)
    post {
        always {
            echo "Pipeline completed - cleaning up"
            // Example: Clean up old containers/images
            sh '''
                docker system prune -f || true
            '''
        }
        success {
            echo "✅ Build succeeded!"
            // Example: Slack notification
            // slackSend color: 'good', message: "Build ${BUILD_NUMBER} succeeded!"
        }
        failure {
            echo "❌ Build failed!"
            // slackSend color: 'danger', message: "Build ${BUILD_NUMBER} failed!"
        }
    }
}
