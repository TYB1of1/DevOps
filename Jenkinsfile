pipeline {
  agent {
    docker {
      image 'my-jenkins-with-docker'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/TYB1of1/DevOps.git'
      }
    }

    stage('Build') {
      agent {
        docker {
          image 'my-jenkins-with-docker'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
          reuseNode true
        }
      }
      steps {
        script {
          sh '''
            echo "Building Docker image..."
            docker version
            docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
            echo "Built image: ${IMAGE_NAME}:${BUILD_NUMBER}"
          '''
        }
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
        script {
          sh '''
            echo "Running tests..."
            docker run --rm ${IMAGE_NAME}:${BUILD_NUMBER} npm test
          '''
        }
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
        script {
          sh '''
            echo "Tagging image..."
            docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
            echo "Pushing image..."
            # docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
            # docker push ${IMAGE_NAME}:${BUILD_NUMBER}
            # docker push ${IMAGE_NAME}:latest
            echo "Deploy done."
          '''
        }
      }
    }
  }

  environment {
    IMAGE_NAME = "my-app"
    BUILD_NUMBER = "${env.BUILD_NUMBER}"
  }

  post {
    always {
      script {
        echo "Cleaning up Docker..."
        sh 'docker system prune -f || true'
      }
    }
    success {
      echo "✅ Build succeeded!"
    }
    failure {
      echo "❌ Build failed!"
    }
  }
}
