pipeline {
  agent any

  stages {
    stage ('Install dependencies') {
      steps {
        nodejs(nodeJSInstallationName: 'nodejs 8.9.4') {
          sh '''
            echo "Installing..."
            npm install
            echo "Install dependencies successfully."
            ls -al
          '''
        }
      }
    }

    stage ('Build') {
      steps {
        nodejs(nodeJSInstallationName: 'nodejs 8.9.4') {
          sh 'echo "Build application..."'
          sh 'npm run build'
          sh 'echo "Build application successfully."'
          sh 'ls -al'
        }
        script {
          stash includes: 'build/', name: 'build'
          stash includes: 'docker/', name: 'docker_folder'
        }
      }
    }

    stage ('Test') {
      steps {
        nodejs(nodeJSInstallationName: 'nodejs 8.9.4') {
          sh '''
            echo "Run unit test..."
            npm test
            echo "Run unit test successfully."
          '''
        }
      }
    }

    stage ('Build and Publish docker images') {
      steps {
        script {
          unstash 'build'
          unstash 'docker_folder'
        }
        sh '''
          ls -al
          echo "Starting to build docker image"
          docker build -t orezfu/color-picker:dev-${BUILD_NUMBER} -f docker/Dockerfile .
        '''
        withCredentials([usernamePassword(credentialsId: 'docker_cred', usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD")]) {
          sh """
            echo "${DOCKER_PASSWORD}" | docker login -u ${DOCKER_USERNAME} --password-stdin
            docker push orezfu/color-picker:dev-${BUILD_NUMBER}
          """
        }
      }
    }

    stage ('Deploy application') {
      steps {
        sh "echo 'Deploy to kubernetes'"
        withKubeConfig([credentialsId: 'kubeconfig', serverUrl: 'https://<kubernetes_instance_public_ip>:6443']) {
          sh """
            kubectl apply -f manifests
            kubectl set image deploy color-picker colorpicker=color-picker:dev-${BUILD_NUMBER}
          """
        }
      }
    }
  }
}