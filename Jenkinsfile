pipeline {
    agent {
        docker {
            image 'my-jenkins-with-docker:latest'
            args '--group-add $(stat -c %g /var/run/docker.sock) -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        IMAGE_NAME = 'my-html-site'
        APP_PORT = 8082
        // Get host's docker group ID dynamically
        DOCKER_GID = sh(script: 'stat -c %g /var/run/docker.sock', returnStdout: true).trim()
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    // Verify Docker socket permissions
                    sh '''
                        echo "Docker socket GID: ${DOCKER_GID}"
                        ls -la /var/run/docker.sock
                        groups
                    '''
                }
            }
        }

        stage('Verify Docker') {
            steps {
                retry(3) {
                    sh '''
                        docker --version
                        docker info
                        docker ps
                    '''
                }
            }
        }

        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.IMAGE_NAME}:${env.BUILD_NUMBER}", "--pull .")
                    docker.withRegistry('', '') {
                        docker.image("${env.IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                        docker.image("${env.IMAGE_NAME}:${env.BUILD_NUMBER}").tag('latest')
                    }
                }
            }
        }

        stage('Verify Container') {
            steps {
                sh "docker run --rm ${env.IMAGE_NAME}:${env.BUILD_NUMBER} echo 'Image works!'"
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
            // Additional failure diagnostics
            sh 'docker ps -a'
            sh 'groups jenkins'
        }
    }
}
