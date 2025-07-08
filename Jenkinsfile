pipeline {
    agent {
        docker {
            image 'my-jenkins-with-docker'  // Your custom image with Docker installed
            args '-v /var/run/docker.sock:/var/run/docker.sock -u root'  // Mount Docker socket and run as root
            reuseNode true  // Reuse the workspace from the main agent
        }
    }
    
    environment {
        IMAGE_NAME = "my-app"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Setup Environment') {
            steps {
                script {
                    echo "Initializing build environment"
                    // Verify Docker is accessible
                    sh 'docker --version'
                    
                    // Debugging information
                    sh '''
                        echo "=== System Information ==="
                        echo "Host: $(uname -a)"
                        echo "User: $(whoami)"
                        echo "Groups: $(groups)"
                        echo "Docker Socket:"
                        ls -la /var/run/docker.sock
                        echo "=== Docker Information ==="
                        docker info
                    '''
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh '''
                        echo "Building application image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh '''
                        echo "Running tests..."
                        docker run --rm ${IMAGE_NAME}:${BUILD_NUMBER} npm test
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh '''
                        echo "Tagging image..."
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                        echo "Deployment would happen here"
                        # Actual deployment commands would go here
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed - cleaning up"
            sh 'docker system prune -f || true'  // Clean up unused containers
        }
        success {
            echo "Build succeeded!"
            // Add notifications here
        }
        failure {
            echo "Build failed!"
            sh 'docker ps -a || true'  // Show all containers for debugging
            // Add failure notifications here
        }
    }
}
