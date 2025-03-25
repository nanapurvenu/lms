pipeline {
    agent any
    environment {
        REGISTRY_CREDENTIALS = "dockerhub"
        AWS_CREDENTIALS = 'awscredentials'
        AWS_REGION = "us-west-2"
        KUBECONFIG_CREDENTIALS = 'kubeconfig'
    }
    stages {
        stage('Extract Version') {
            steps {
                script {
                    def packageJson = readJSON file: 'webapp/package.json'
                    env.APP_VERSION = packageJson.version
                    echo "App Version: ${APP_VERSION}"
                }
            }
        }
        stage('Build and Push Docker Images and deploy in containers') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo Logging into Docker Hub as \$DOCKER_USER
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin

                        docker build -t \$DOCKER_USER/lms-fe:${APP_VERSION} webapp/
                        docker build -t \$DOCKER_USER/lms-be:${APP_VERSION} api/

                        docker images
                        docker push \$DOCKER_USER/lms-fe:${APP_VERSION}
                        docker push \$DOCKER_USER/lms-be:${APP_VERSION}
                        """
}

                        """
                    }
                }
            }
        }
       stage('Authenticate with AWS and EKS') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscredentials']]) {
                    sh '''
                        aws eks update-kubeconfig --region $AWS_REGION --name eks
                    '''
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_CREDENTIALS')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_CREDENTIALS
                        echo "Using Kubeconfig: \$KUBECONFIG_CREDENTIALS"
                        sed -i "s|IMAGE_VERSION|${APP_VERSION}|g" deployment.yml
                        kubectl apply -f deployment.yml
                    '''
                }
            }
        }
    }
}