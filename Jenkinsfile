pipeline {
    agent any
    
    environment {
        DOCKER_HOST = "unix:///var/run/docker.sock"
    }
    
    stages {
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
                    sh '''
                        echo "=== Debugging Information ==="
                        echo "Current user: $(whoami)"
                        echo "Docker socket permissions:"
                        ls -la /var/run/docker.sock
                        echo "User groups:"
                        groups
                        echo "Docker version:"
                        docker --version
                        echo "Trying to list containers:"
                        docker ps
                    '''
                }
            }
        }
    }
}
