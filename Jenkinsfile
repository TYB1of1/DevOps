pipeline {
    agent any

    environment {
        // Docker image configuration
        IMAGE_NAME = "my-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // Credential IDs (configure these in Jenkins)
        GIT_CREDENTIALS_ID = 'github-credentials'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        
        // Workspace paths
        WORKSPACE_PATH = "${env.WORKSPACE}"
    }

    options {
        // Discard old builds to save space
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        
        // Retry once if failed
        retry(1)
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "Initializing build ${env.BUILD_NUMBER}"
                    echo "Workspace: ${WORKSPACE_PATH}"
                }
            }
        }

        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        url: 'https://github.com/TYB1of1/DevOps.git'
                    ]]
                ])
                sh 'git --version'
                sh 'ls -al'
            }
        }

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'my-jenkins-with-docker'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo "Building Docker image..."
                    sh """
                        docker version
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker images
                    """
                }
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image 'my-jenkins-with-docker'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo "Running tests..."
                    sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test"
                }
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            agent {
                docker {
                    image 'my-jenkins-with-docker'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS_ID}",
                        passwordVariable: 'DOCKER_PASSWORD',
                        usernameVariable: 'DOCKER_USERNAME'
                    )]) {
                        sh """
                            echo "Logging in to Docker Hub..."
                            echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                            
                            echo "Tagging and pushing image..."
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:latest
                            
                            docker push \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}
                            docker push \$DOCKER_USERNAME/${IMAGE_NAME}:latest
                            
                            docker logout
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
                script {
                    echo "Deployment would happen here"
                    // Add your deployment commands (kubectl, ansible, etc.)
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed - cleaning up"
            script {
                // Only try to clean up if we're on a node with Docker
                if (isUnix()) {
                    try {
                        sh 'docker system prune -f --filter "until=24h" || true'
                    } catch (Exception e) {
                        echo "Cleanup failed: ${e.getMessage()}"
                    }
                }
            }
            }
            cleanWs()
        }
        success {
            echo "✅ Pipeline succeeded!"
            slackSend(color: 'good', message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
        }
        failure {
            echo "❌ Pipeline failed!"
            slackSend(color: 'danger', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
        }
        unstable {
            echo "⚠️ Pipeline unstable!"
            slackSend(color: 'warning', message: "UNSTABLE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
        }
    }
