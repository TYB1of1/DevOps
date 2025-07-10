pipeline {
  agent any

  environment {
    IMAGE_NAME = "my-app"
    BUILD_NUMBER = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Build') {
      agent {
        docker {
          image 'my-jenkins-with-docker'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
          reuseNode true
        }
      }
      steps {
        sh 'docker version'
        sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
      }
    }

    stage('Test') {
      agent {
        docker {
          image 'my-jenkins-with-docker'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
          reuseNode true
        }
      }
      steps {
        sh 'docker run --rm ${IMAGE_NAME}:${BUILD_NUMBER} npm test'
      }
    }

    stage('Deploy') {
      agent {
        docker {
          image 'my-jenkins-with-docker'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
          reuseNode true
        }
      }
      steps {
        sh '''
          docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
          echo "Would push here if you uncomment the push commands"
          # docker push ${IMAGE_NAME}:${BUILD_NUMBER}
          # docker push ${IMAGE_NAME}:latest
        '''
      }
    }
  }

  post {
    always {
      echo 'Pipeline done. Cleaning up.'
      sh 'docker system prune -f || true'
    }
    success {
      echo '✅ Build succeeded!'
    }
    failure {
      echo '❌ Build failed!'
    }
  }
}
