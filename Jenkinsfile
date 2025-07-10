pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
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
            }
        }

        stage('Check Git Version') {
            steps {
                sh 'git --version'
            }
        }

        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/TYB1of1/DevOps.git'

                sh 'ls -al'
            }
        }

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                echo "Building Docker image..."
                sh """
                    docker version
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker images
                """
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                echo "Running tests..."
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test"
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS_ID}",
                    passwordVariable: 'DOCKER_PASSWORD',
                    usernameVariable: 'DOCKER_USERNAME'
                )]) {
                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin

                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:latest

                        docker push \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push \$DOCKER_USERNAME/${IMAGE_NAME}:latest

                        docker logout
                    """
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "Deployment would happen here"
                // Add your actual deployment logic here
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
            script {
                if (isUnix()) {
                    sh 'docker system prune -f --filter "until=24h" || true'
                }
            }
            cleanWs()
        }
        success {
            echo "✅ Pipeline succeeded!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        unstable {
            echo "⚠️ Pipeline unstable!"
        }
    }
}
