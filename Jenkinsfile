pipeline {
    agent any

    environment {
        REGISTRY_CREDENTIALS = "dockerhub"
        AWS_CREDENTIALS = "awscredentials"
        AWS_REGION = "us-west-2"
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

        stage('Build and Push Docker Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo Logging into Docker Hub as \$DOCKER_USER
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin

                            docker build -t venureddy3417/lms-fe:\${APP_VERSION} webapp/
                            docker build -t venureddy3417/lms-be:\${APP_VERSION} api/

                            docker images
                            docker push venureddy3417/lms-fe:\${APP_VERSION}
                            docker push venureddy3417/lms-be:\${APP_VERSION}
                        """
                    }
                }
            }
        }

        stage('Authenticate with AWS and EKS') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: AWS_CREDENTIALS, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    withEnv([
                        "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}",
                        "AWS_DEFAULT_REGION=${AWS_REGION}"
                    ]) {
                        sh '''
                            echo "🔐 Authenticating with AWS..."
                            aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks --interactive-mode=non-interactive
                        '''
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "🚀 Deploying to EKS..."
                    sed -i "s|IMAGE_VERSION|${APP_VERSION}|g" deployment.yml
                    kubectl apply -f deployment.yml
                '''
            }
        }
    }
}
