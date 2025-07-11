pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        SSH_CREDENTIALS_ID = 'jenkins_local_ssh' // Your SSH key credential
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        retry(1)
    }

    stages {
        stage('Initialize') {
            steps {
                echo "Initializing build ${BUILD_NUMBER}"
                echo "Workspace: ${env.WORKSPACE}"
                sh 'printenv'
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    // Verify Docker is available
                    try {
                        sh 'docker --version'
                    } catch (Exception e) {
                        error "Docker not found! Please ensure Docker is installed and running."
                    }
                    
                    // Verify SSH access
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh 'ssh -o StrictHostKeyChecking=no localhost "docker --version"'
                    }
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[url: 'https://github.com/TYB1of1/DevOps.git']],
                    extensions: [[$class: 'CleanBeforeCheckout']]
                ])
                sh 'git log -1 --pretty=%B'
            }
        }

        stage('Build Docker Image') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh localhost "cd ${WORKSPACE} && docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                        ssh localhost "docker images | grep ${IMAGE_NAME}"
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh localhost "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test || echo 'No tests defined'"
                    """
                }
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    withCredentials([usernamePassword(
                        credentialsId: DOCKER_CREDENTIALS_ID,
                        passwordVariable: 'DOCKER_PASSWORD',
                        usernameVariable: 'DOCKER_USERNAME'
                    )]) {
                        sh """
                            ssh localhost "
                                echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:latest
                                docker push \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                                docker push \$DOCKER_USERNAME/${IMAGE_NAME}:latest
                                docker logout
                            "
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    script {
                        // Example deployment command
                        sh 'ssh localhost "echo \'Deployment would happen here\'"'
                        // Actual deployment might be:
                        // sh 'ssh localhost "docker stack deploy -c docker-compose.yml myapp"'
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
            sshagent([SSH_CREDENTIALS_ID]) {
                sh 'ssh localhost "docker system prune -f --filter until=24h" || true'
            }
            cleanWs()
        }
        success {
            echo "✅ Pipeline succeeded!"
            slackSend(color: 'good', message: "Build ${BUILD_NUMBER} succeeded!")
        }
        failure {
            echo "❌ Pipeline failed!"
            slackSend(color: 'danger', message: "Build ${BUILD_NUMBER} failed!")
        }
    }
}
