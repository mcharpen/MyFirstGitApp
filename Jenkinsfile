pipeline {
    agent { label 'DEV2' }


    stages {

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.BRANCH_NAME ]],
                    userRemoteConfigs: [[ url: 'https://github.com/mcharpen/MyFirstGitApp.git' ]]
                ])
            }
        }

        stage('Docker Compose Restart') {
            steps {
                echo "Restarting docker-compose project on dev2..."

                sh """
                    docker compose down -v || true
                    docker compose up --build -d
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Deployment failed for branch: ${env.BRANCH_NAME}"
        }
    }
}

