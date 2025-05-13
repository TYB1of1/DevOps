pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/TYB1of1/DevOps.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('my-html-site')
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    docker.image('my-html-site').run('-d -p 8080:80')
                }
            }
        }
    }
}
