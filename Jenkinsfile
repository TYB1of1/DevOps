pipeline {
    agent any
    
    stages {
        stage('Build and Test') {
            agent {
                docker {
                    image 'my-jenkins-with-docker:latest'
                    args '-v /Users/theoboakye/.docker/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                        echo "Docker socket mounted at:"
                        ls -la /var/run/docker.sock
                        docker --version
                        docker ps
                    '''
                }
            }
        }
    }
}
