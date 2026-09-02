pipeline {

    agent any

    environment {

        // GitHub
        GIT_REPO = 'https://github.com/vasusamgithub/project2.git'
        GIT_BRANCH = 'dev2'
        GITHUB_CREDENTIALS = 'githubbbig'

        // DockerHub
        DOCKER_IMAGE = 'vasu6303935331/project1'
        DOCKER_CREDENTIALS = 'dockerbig'

        // SonarQube Jenkins configuration name
        SONAR_SERVER = 'sonarbig'

        // SonarQube Jenkins credential ID
        SONAR_CREDENTIALS = 'sonar-token'

        // Kubernetes deployment file
        YAML_FILE = 'deployment.yaml'
    }

    stages {

        // 1. Git Clone
        stage('Git Clone') {
            steps {
                git(
                    branch: "${GIT_BRANCH}",
                    credentialsId: "${GITHUB_CREDENTIALS}",
                    url: "${GIT_REPO}"
                )
            }
        }

        // 2. Maven Build
        stage('Maven Build') {
            steps {
                sh '''
                    mvn clean package -DskipTests
                '''
            }
        }

        // 3. SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {

                    withCredentials([
                        string(
                            credentialsId: "${SONAR_CREDENTIALS}",
                            variable: 'SONAR_TOKEN'
                        )
                    ]) {

                        sh '''
                            mvn org.sonarsource.scanner.maven:sonar-maven-plugin:5.7.0.6970:sonar \
                            -Dsonar.projectKey=my-project \
                            -Dsonar.projectName=my-project \
                            -Dsonar.token="$SONAR_TOKEN"
                        '''
                    }
                }
            }
        }

        // 5. Docker Image Creation
        stage('Docker Image Creation') {
            steps {
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                '''
            }
        }

        // 6. Trivy Image Scan
        stage('Trivy Scan') {
            steps {
                sh '''
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        // 7. DockerHub Push
        stage('DockerHub Push') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                        -u "$DOCKER_USERNAME" \
                        --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}

                        docker tag \
                        ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        ${DOCKER_IMAGE}:latest

                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        // 8. Update Kubernetes YAML
        stage('Update YAML Image') {
            steps {
                sh '''
                    sed -i "s|image:.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g" ${YAML_FILE}

                    echo "Updated YAML:"
                    cat ${YAML_FILE}
                '''
            }
        }

        // 9. Push YAML to GitHub
        stage('Push YAML to GitHub') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: "${GITHUB_CREDENTIALS}",
                        usernameVariable: 'GITHUB_USERNAME',
                        passwordVariable: 'GITHUB_TOKEN'
                    )
                ]) {

                    sh '''
                        git config user.name "Jenkins"
                        git config user.email "jenkins@example.com"

                        git add ${YAML_FILE}

                        git commit \
                        -m "Update Docker image to ${BUILD_NUMBER}" || true

                        git push \
                        https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/vasusamgithub/project2.git \
                        HEAD:${GIT_BRANCH}
                    '''
                }
            }
        }
    }

    post {

        success {
            echo "Pipeline completed successfully!"
            echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            echo "YAML updated successfully."
        }

        failure {
            echo "Pipeline failed!"
        }
    }
}
