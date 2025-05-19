pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                // Explicitly specify the branch name
                git url: 'https://github.com/TYB1of1/DevOps.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('my-html-site')
                }
            }
        }

        stage('Stop Previous Containers') {
            steps {
                script {
                    // Consider adding '|| true' if you don't want the build to fail if no containers are found
                    sh 'docker ps -q --filter "ancestor=my-html-site" | xargs -r docker stop || true'
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    docker.image('my-html-site').run('-d -p 8082:80')
                }
            }
        }
    }
}
