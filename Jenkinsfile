pipeline {
    agent any
    
    environment {
        DOCKER_HOST = "unix:///var/run/docker.sock"
        // Set build-specific variables
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
                }
            }
        }
        
        stage('Build and Test') {
            agent {
                docker {
                    image 'my-jenkins-with-docker:latest'
                    args '-v /Users/theoboakye/.docker/run/docker.sock:/var/run/docker.sock -u root'
                    reuseNode true
                }
            }
            steps {
                script {
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
                    
                    // Sample build process
                    sh '''
                        echo "Building application image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                        
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
                        echo "Deploying ${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                        # Add your deployment commands here
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed - cleaning up"
            sh 'docker system prune -f'  // Clean up unused containers
        }
        success {
            echo "Build succeeded!"
            // Add notifications here
        }
        failure {
            echo "Build failed!"
            sh 'docker ps -a'  // Show all containers for debugging
            // Add failure notifications here
        }
    }
}
