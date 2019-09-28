
pipeline {

   environment {
      REGISTRY = # TODO: Add ECR location to environment
      IMAGE = # TODO: Add container image to environment
   }
   agent any
   stages {
      stage('Lint HTML') {
         steps {
            sh 'tidy -q -e app/*.html'
         }
      }
      stage('Lint Python') {
        steps {
            sh 'pylint --disable=R,C,W1203 *.py'
            }
      }
      {
        stage('Format Python') {
          sh 'black atlas/*.py'
        }
      }
      stage('Lint Dockerfile') {
         steps {
            sh 'wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64 &&\
            chmod +x /bin/hadolint &&\
            make docker-lint'
         }
      }
      stage('Build Image') {
         steps {
            script{
               sh "make docker-build"
            }
         }
      }
      stage('Push Image'){
         steps {
            script{
               sh "make docker-push"
            }
         }
      }
      stage('Deploy Kubernetes'){
        steps{
            script{
                sh "make kube-deploy"
            }
        }
      }
   }
}