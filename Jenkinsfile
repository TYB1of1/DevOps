pipeline {
    agent none  // We'll declare agents per stage
    
    environment {
        // Infrastructure Configuration
        DOCKER_SOCKET_PATH = "/Users/theoboakye/.docker/run/docker.sock"
        DOCKER_HOST = "unix://${DOCKER_SOCKET_PATH}"
        
        // Application Configuration
        IMAGE_NAME = "my-app"
        BUILD_TAG = "build-${env.BUILD_NUMBER}"
        DEPLOY_REGION = "us-east-1"  // For AWS deployments
        
        // Tool Versions
        NODE_VERSION = "18.x"
        DOCKER_COMPOSE_VERSION = "v2"
    }
    
    stages {
        stage('Setup Environment') {
            agent any
            steps {
                script {
                    echo "### INITIALIZING BUILD ENVIRONMENT ###"
                    
                    // Verify Docker is available
                    sh """
                        echo 'Docker Socket Path: ${DOCKER_SOCKET_PATH}'
                        ls -la ${DOCKER_SOCKET_PATH} || true
                        echo '--- Docker Version ---'
                        docker --version || echo "Docker not available on host"
                    """
                    
                    // Setup tool versions (example with Node)
                    sh """
                        echo '--- Setting Up Node ${NODE_VERSION} ---'
                        curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | sudo -E bash -
                        sudo apt-get install -y nodejs
                    """
                    
                    // Store environment info
                    sh """
                        echo '--- Environment Summary ---'
                        echo "Build Tag: ${BUILD_TAG}"
                        echo "Deploy Region: ${DEPLOY_REGION}"
                        uname -a
                        node --version
                        npm --version
                        docker-compose version
                    """
                    
                    // Create needed directories
                    sh 'mkdir -p ./build/logs'
                }
            }
        }

        stage('Build') {
            agent {
                docker {
                    image 'my-jenkins-with-docker:latest'
                    args "-v ${DOCKER_SOCKET_PATH}:/var/run/docker.sock -u root -e HOME=${workspace}"
                    reuseNode true
                }
            }
            steps {
                script {
                    sh """
                        echo '### BUILDING APPLICATION ###'
                        docker build -t ${IMAGE_NAME}:${BUILD_TAG} \
                            --build-arg NODE_ENV=production \
                            .
                        docker tag ${IMAGE_NAME}:${BUILD_TAG} ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Test') {
            agent {
                docker {
                    image 'my-jenkins-with-docker:latest'
                    args "-v ${DOCKER_SOCKET_PATH}:/var/run/docker.sock -u root -e CI=true"
                    reuseNode true
                }
            }
            steps {
                script {
                    sh """
                        echo '### RUNNING TESTS ###'
                        docker run --rm ${IMAGE_NAME}:${BUILD_TAG} \
                            npm run test:ci
                        
                        echo '--- Running Security Scan ---'
                        docker run --rm -v ${workspace}:/app \
                            aquasec/trivy:latest \
                            image --severity HIGH,CRITICAL ${IMAGE_NAME}:${BUILD_TAG}
                    """
                }
            }
        }

        stage('Deploy') {
            agent any
            when {
                expression { 
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'develop'
                }
            }
            steps {
                script {
                    echo "### DEPLOYING TO ${DEPLOY_REGION} ###"
                    
                    // AWS ECR Example
                    withAWS(region: DEPLOY_REGION, credentials: 'aws-jenkins') {
                        sh """
                            aws ecr get-login-password | docker login \
                                --username AWS \
                                --password-stdin 123456789.dkr.ecr.${DEPLOY_REGION}.amazonaws.com
                                
                            docker tag ${IMAGE_NAME}:${BUILD_TAG} \
                                123456789.dkr.ecr.${DEPLOY_REGION}.amazonaws.com/${IMAGE_NAME}:${BUILD_TAG}
                                
                            docker push \
                                123456789.dkr.ecr.${DEPLOY_REGION}.amazonaws.com/${IMAGE_NAME}:${BUILD_TAG}
                        """
                        
                        // Kubernetes deployment
                        sh """
                            kubectl set image deployment/${IMAGE_NAME} \
                                ${IMAGE_NAME}=123456789.dkr.ecr.${DEPLOY_REGION}.amazonaws.com/${IMAGE_NAME}:${BUILD_TAG} \
                                --namespace=${DEPLOY_ENV}
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "### CLEANUP ###"
            sh 'docker system prune -f --filter "until=24h"'
            cleanWs()
        }
        success {
            slackSend(
                channel: '#builds',
                message: """SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}
                | Image: ${IMAGE_NAME}:${BUILD_TAG}
                | Branch: ${env.BRANCH_NAME}
                | View: ${env.BUILD_URL}"""
            )
        }
        failure {
            slackSend(
                channel: '#build-alerts',
                color: 'danger',
                message: """FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}
                | Branch: ${env.BRANCH_NAME}
                | Logs: ${env.BUILD_URL}console"""
            )
            archiveArtifacts artifacts: '**/build/logs/*.log', allowEmptyArchive: true
        }
    }
}
