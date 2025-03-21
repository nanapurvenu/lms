pipeline {
    agent any
    environment {
        REGISTRY_CREDENTIALS = "dockerhub"
        NETWORK_NAME = "lms-network"
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
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t venureddy3417/lms-fe:${APP_VERSION} webapp/
                        docker build -t venureddy3417/lms-be:${APP_VERSION} api/
                        docker push venureddy3417/lms-fe:${APP_VERSION}
                        docker push venureddy3417/lms-be:${APP_VERSION}
                        """
                    }
                }
            }
        }
        stage('Deploy on Docker Server') {
            steps {
                script {
                    sh """
                    # Stop and remove old containers in the network
                    docker ps --filter "network=${NETWORK_NAME}" -q | xargs -r docker rm -f
                    docker network rm ${NETWORK_NAME} || true
                    docker network create ${NETWORK_NAME} || true
                    # Start Database Container
                    docker container rm -f lms-db || true
                    docker container run -dt --name lms-db -e POSTGRES_PASSWORD=app12345 postgres
                    # Start Backend Container
                    docker pull venureddy3417/lms-be:${APP_VERSION}
                    docker container rm -f lms-be || true
                    docker container run -dt --name lms-be -p 8081:8080 \
                        -e POSTGRES_DB=lmsdb
                        -e DATABASE_URL="postgresql://postgres:app12345@lms-db:5432/lmsdb?schema=public" \
                        --network ${NETWORK_NAME} venureddy3417/lms-be:${APP_VERSION}
                    # Start Frontend Container
                    docker pull venureddy3417/lms-fe:${APP_VERSION}
                    docker container rm -f lms-fe || true
                    docker container run -dt --name lms-fe -p 80:80 \
                        --network ${NETWORK_NAME} venureddy3417/lms-fe:${APP_VERSION}
                    """
                }
            }
        }
    }
}









