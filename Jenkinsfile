def registry  = 'https://trial65h59b.jfrog.io'
def imageName = 'trial65h59b.jfrog.io/nandini-docker-local/demo-workshop'
def version   = '2.1.2'

pipeline {
    agent {
        node {
            label 'maven'
        }
    }

    environment {
        PATH = "/opt/maven/bin:$PATH"
    }

    stages {

        stage("build") {
            steps {
                echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "----------- build completed ----------"
            }
        }

        stage("test") {
            steps {
                echo "----------- unit test started ----------"
                sh 'mvn surefire-report:report'
                echo "----------- unit test completed ----------"
            }
        }

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage("Quality Gate") {
            steps {
                echo "----------- SonarQube Analysis Successful ----------"
                echo "----------- View results at https://sonarcloud.io ----------"
            }
        }

        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                    withCredentials([usernamePassword(
                        credentialsId: 'jfrog_cred',
                        usernameVariable: 'JFROG_USER',
                        passwordVariable: 'JFROG_TOKEN'
                    )]) {
                        sh '''
                            find jarstaging/ -type f ! -name "*.sha1" ! -name "*.md5" | while read filepath; do
                                relpath=$(echo "$filepath" | sed 's|jarstaging/||')
                                echo "Uploading: $filepath"
                                curl -u ${JFROG_USER}:${JFROG_TOKEN} \
                                     -X PUT \
                                     "https://trial65h59b.jfrog.io/artifactory/maven-libs-release-local/${relpath}" \
                                     -T "$filepath"
                                echo "Uploaded: $relpath"
                            done
                        '''
                    }
                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    echo '<--------------- Docker Build Started --------------->'
                    app = docker.build(imageName + ":" + version)
                    echo '<--------------- Docker Build Ended --------------->'
                }
            }
        }

        stage("Docker Publish") {
            steps {
                script {
                    echo '<--------------- Docker Publish Started --------------->'
                    docker.withRegistry(registry, 'jfrog_cred') {
                        app.push()
                    }
                    echo '<--------------- Docker Publish Ended --------------->'
                }
            }
        }

        // stage("Deploy") {
        //     steps {
        //         script {
        //             sh 'helm install demo-workshop demo-workshop-1.0.0'
        //         }
        //     }
        // }

    }
}
