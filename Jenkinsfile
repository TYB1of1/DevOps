// DevOps/Jenkinsfile

pipeline {
    // In your Jenkinsfile
// In your Jenkinsfile
agent {
    docker {
        image 'my-jenkins-with-docker:latest'
        // Mount the socket and add the container's user to host GID 20
        args '-v /var/run/docker.sock:/var/run/docker.sock --group-add 20'
        reuseNode true
    }
}

    environment {
        IMAGE_NAME = 'my-html-site' // Name for your application's Docker image
        APP_CONTAINER_NAME = 'my-html-site-container' // Name for the running app container
        APP_PORT = 8082 // Port to expose on the host
        REPO_URL = 'https://github.com/TYB1of1/DevOps.git' // Your repository URL
        BRANCH_NAME = 'main' // Or the branch you are working on
        // The Jenkins workspace will be something like /var/jenkins_home/workspace/your_pipeline_name
        // When checkout scm runs, 'portfolio' dir will be inside this workspace
        // So, context for commands related to app code will be workspace/portfolio
    }

    stages {
        stage('Initialize Agent') {
            steps {
                script {
                    echo "Running in agent: ${env.NODE_NAME}"
                    echo "Verifying Docker client..."
                    sh 'docker --version'
                    sh 'docker info' // Check connection to Docker daemon
                    echo "Verifying Node.js and npm..."
                    sh 'node --version'
                    sh 'npm --version'
                }
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Checking out code from ${env.REPO_URL} branch ${env.BRANCH_NAME}"
                // This will checkout the entire repository content into the workspace.
                // Your Jenkinsfile, Dockerfile, html, css will be under workspace/portfolio/
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.BRANCH_NAME]],
                    userRemoteConfigs: [[url: env.REPO_URL]]
                ])
                // List files to confirm structure after checkout
                sh 'ls -la' // Lists content of workspace root
                dir('portfolio') {
                    sh 'pwd' // Should show workspace/portfolio
                    sh 'ls -la' // Lists content of workspace/portfolio
                }
            }
        }

        stage('Install Test Dependencies') {
            steps {
                // All commands in this 'dir' block execute within 'workspace/portfolio'
                dir('portfolio') {
                    echo "Installing npm dependencies for testing in portfolio directory..."
                    sh 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('portfolio') {
                    script {
                        echo "Running HTML Validation..."
                        try {
                            // npx will use the tools installed locally via package.json
                            sh 'npx html-validator --glob "**/*.html"'
                            echo "HTML Validation Passed."
                        } catch (Exception e) {
                            echo "HTML Validation Failed: ${e.getMessage()}"
                            currentBuild.result = 'FAILURE'
                            error("HTML Validation Failed. Halting pipeline.")
                        }

                        echo "Running CSS Linting..."
                        try {
                            sh 'npx stylelint "**/*.css"'
                            echo "CSS Linting Passed."
                        } catch (Exception e) {
                            echo "CSS Linting Failed: ${e.getMessage()}"
                            currentBuild.result = 'FAILURE'
                            error("CSS Linting Failed. Halting pipeline.")
                        }
                    }
                }
            }
        }

        stage('Build Application Docker Image') {
            steps {
                // The build context for the app's Docker image is 'portfolio'
                // The app's Dockerfile is also inside 'portfolio'
                dir('portfolio') {
                    script {
                        echo "Building Docker image: ${env.IMAGE_NAME} from portfolio directory..."
                        // Dockerfile (for the app) is expected in the current dir ('portfolio')
                        sh "docker build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
                        sh "docker tag ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.IMAGE_NAME}:latest"
                        echo "Image ${env.IMAGE_NAME}:${env.BUILD_NUMBER} and ${env.IMAGE_NAME}:latest built."
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    echo "Deploying application container: ${env.APP_CONTAINER_NAME}..."
                    // Stop and remove old container if it exists
                    sh "docker stop ${env.APP_CONTAINER_NAME} || true"
                    sh "docker rm ${env.APP_CONTAINER_NAME} || true"

                    // Run new container
                    sh "docker run -d --name ${env.APP_CONTAINER_NAME} -p ${env.APP_PORT}:80 ${env.IMAGE_NAME}:latest"
                    echo "Application deployed and accessible on http://localhost:${env.APP_PORT}"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        success {
            echo 'Pipeline Succeeded!'
        }
        failure {
            echo 'Pipeline Failed!'
        }
    }
}
