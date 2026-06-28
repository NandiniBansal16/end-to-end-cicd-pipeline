// ─── CHANGE THESE 3 LINES TO YOUR VALUES ───────────────────────
def registry  = 'https://trial65h59b.jfrog.io'
// ↑ Replace YOUR_JFROG_NAME with your JFrog account name
// Example: 'https://johnsmith.jfrog.io'

def imageName = 'trial65h59b.jfrog.io/nandini-docker-local/demo-workshop'
// ↑ Replace YOUR_JFROG_NAME and YOUR_DOCKER_REPO_NAME
// Keep demo-workshop — it matches your artifactId in pom.xml
// Example: 'johnsmith.jfrog.io/john-docker-local/demo-workshop'

def version   = '2.1.2'
// ↑ DO NOT change this — it must exactly match <version> in pom.xml
// ────────────────────────────────────────────────────────────────

pipeline {
    agent {
        node {
            label 'maven'
            // ↑ DO NOT change — must match the label you set in Step 4
            // when you created the jenkins agent node
        }
    }

    environment {
        PATH = "/opt/maven/bin:$PATH"
        // ↑ Changed from original /opt/apache-maven-3.9.4/bin
        // to /opt/maven/bin because in Step 3 we created a symlink
        // at /opt/maven pointing to apache-maven-3.9.16
        // This is the correct path for YOUR installation
    }

    stages {

        stage("build") {
            steps {
                echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                // ↑ mvn clean = wipe previous build output
                // deploy = compile + package + copy JAR to jarstaging/
                // -Dmaven.test.skip=true = skip tests here, run them in next stage
                echo "----------- build completed ----------"
            }
        }

        stage("test") {
            steps {
                echo "----------- unit test started ----------"
                sh 'mvn surefire-report:report'
                // ↑ Runs JUnit tests and generates HTML test report
                // Also runs JaCoCo to measure code coverage
                // Coverage report goes to target/site/jacoco/jacoco.xml
                // SonarQube reads that file in the next stage
                echo "----------- unit test completed ----------"
            }
        }

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'sonar-scanner'
                // ↑ Replace YOUR_SONAR_SCANNER_NAME with the exact name
                // you typed in Jenkins → Manage Jenkins → Tools →
                // SonarQube Scanner → Name field in Step 4
                // Example: tool 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {
                // ↑ Replace YOUR_SONAR_SERVER_NAME with the exact name
                // you typed in Jenkins → Manage Jenkins → System →
                // SonarQube servers → Name field in Step 4
                // Example: withSonarQubeEnv('sonarqube-server')
                    sh "${scannerHome}/bin/sonar-scanner"
                    // ↑ Runs the scanner using sonar-project.properties
                    // file in your repo root for configuration
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        // ↑ Pauses the pipeline and waits for SonarCloud
                        // to finish analyzing and send back a pass/fail result
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            // ↑ If code quality is bad, pipeline stops HERE
                            // Nothing gets deployed — that is the whole point
                        }
                    }
                }
            }
        }

        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer(
                        url: registry + "/artifactory",
                        credentialsId: "jfrog_cred"
                        // ↑ DO NOT change jfrog_cred
                        // This must exactly match the credential ID
                        // you created in Jenkins in Step 4
                    )
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}"
                    // ↑ Tags the JAR in JFrog with build number and git commit
                    // So you can always trace which code produced which JAR

                    def uploadSpec = """{
                        "files": [{
                            "pattern": "jarstaging/(*)",
                            "target": "maven-libs-release-local/{1}",
                            "flat": "false",
                            "props": "${properties}",
                            "exclusions": ["*.sha1", "*.md5"]
                        }]
                    }"""
                    // ↑ pattern: picks up everything inside jarstaging/
                    //   jarstaging/ is where pom.xml puts the JAR after
                    //   'mvn clean deploy' in the build stage.
                    // ↑ target: uploads to maven-libs-release-local repo
                    //   in JFrog — make sure this repo exists in your JFrog

                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    echo '<--------------- Docker Build Started --------------->'
                    app = docker.build(imageName + ":" + version)
                    // ↑ Runs: docker build -t YOUR_IMAGE_NAME:2.1.2 .
                    // Uses your Dockerfile in the repo root
                    // The Dockerfile picks up the JAR from jarstaging/
                    echo '<--------------- Docker Build Ended --------------->'
                }
            }
        }

        stage("Docker Publish") {
            steps {
                script {
                    echo '<--------------- Docker Publish Started --------------->'
                    docker.withRegistry(registry, 'jfrog_cred') {
                    // ↑ Logs into your JFrog Docker registry using jfrog_cred
                        app.push()
                        // ↑ Pushes the image to JFrog Docker repo
                    }
                    echo '<--------------- Docker Publish Ended --------------->'
                }
            }
        }

        stage("Deploy") {
            steps {
                script {
                    echo '<--------------- Helm Deploy Started --------------->'
                    sh 'helm install demo-workshop demo-workshop-1.0.0'
                    // ↑ Changed from: helm install sample-app sample-app-1.0.1
                    // demo-workshop = release name (what Helm calls this deployment)
                    // demo-workshop-1.0.0 = your Helm chart file name
                    // You will create this chart in Step 11
                    // Leave this stage commented out until Step 11 is done
                    echo '<--------------- Helm Deploy Ended --------------->'
                }
            }
        }

    }
}
