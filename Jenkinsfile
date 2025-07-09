pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "my-app"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
stages {
    stage('Prepare Docker (DinD)') {
        agent {
            docker {
                image 'docker:dind'  // Official DinD image
                args '--privileged'  // Required for DinD
                reuseNode true
            }
        }
        steps {
            script {
                sh 'docker --version'
                sh 'docker info'
            }
        }
    }
}
        
        stage('Build') {
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
                        echo "Building application image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    '''
                }
            }
        }
        
        stage('Test') {
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
                        echo "Running tests..."
                        docker run --rm ${IMAGE_NAME}:${BUILD_NUMBER} npm test
                    '''
                }
            }
        }
        
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
                        echo "Tagging image..."
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                        echo "Deploying image..."
                        # Add your actual deployment commands here
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed - cleaning up"
        }
        success {
            echo "Build succeeded!"
        }
        failure {
            echo "Build failed!"
        }
    }
}
