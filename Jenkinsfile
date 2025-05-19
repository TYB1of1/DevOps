
pipeline {
    agent any // Runs on any available agent

    environment {
        // Define image name for consistency
        IMAGE_NAME = 'my-html-site' // Your GitHub username could be a prefix: 'tyb1of1/my-html-site'
        // Define the public port for the application
        APP_PORT = 8082
    }

    stages {
        stage('Clone Repo') {
            steps {
                echo 'Cloning repository...'
                // Explicitly specify the branch name
                git url: 'https://github.com/TYB1of1/DevOps.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${env.IMAGE_NAME}..."
                    // Assumes Dockerfile is in the root of the repository
                    docker.build("${env.IMAGE_NAME}:${env.BUILD_NUMBER}", ".") // Tag with build number
                    docker.build("${env.IMAGE_NAME}:latest", ".")      // Also tag as latest
                }
            }
        }

        stage('Test HTML') {
            steps {
                script {
                    echo 'Validating HTML files...'
                    // Ensure your HTML files are in the 'portfolio' directory
                    // Add all important HTML files you want to validate
                    sh 'docker run --rm -v $(pwd)/portfolio:/mnt dcycle/html-validator:latest /mnt/index.html'
                    // sh 'docker run --rm -v $(pwd)/portfolio:/mnt dcycle/html-validator:latest /mnt/another-page.html'
                    echo 'HTML validation passed.'
                }
            }
        }



        stage('Stop Previous Containers') {
            steps {
                script {
                    echo "Stopping any existing containers for image: ${env.IMAGE_NAME}..."
                    // Stop containers based on the image name rather than any container using the port
                    // The -r flag for xargs means it won't run if there's no input
                    sh "docker ps -q --filter \"ancestor=${env.IMAGE_NAME}\" | xargs -r docker stop || true"
                    sh "docker ps -aq --filter \"ancestor=${env.IMAGE_NAME}\" | xargs -r docker rm || true" // Remove stopped containers
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    echo "Running Docker container from image: ${env.IMAGE_NAME}:${env.BUILD_NUMBER} on port ${env.APP_PORT}..."
                    // Run the version tagged with the build number
                    docker.image("${env.IMAGE_NAME}:${env.BUILD_NUMBER}").run("-d -p ${env.APP_PORT}:80")
                }
            }
        }

        stage('Smoke Test Deployed Site') {
            steps {
                script {
                    echo "Performing smoke test on deployed site at http://localhost:${env.APP_PORT}..."
                    sh 'sleep 10' // Give container a moment to initialize
                    // Check if the site is accessible
                    // The -f flag fails silently on server errors, -s for silent, -S to show error on fail
                    sh "curl -sSf http://localhost:${env.APP_PORT} || (echo 'Smoke test failed!' && exit 1)"
                    echo "Site is up and running on port ${env.APP_PORT}!"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            // Clean up old images if desired (be careful with this in production)
            // sh 'docker rmi $(docker images -f "dangling=true" -q) || true'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
            // Add notification steps here if desired (e.g., email, Slack)
        }
    }
}
