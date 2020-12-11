/**
 * The name of the master branch
 */
def MASTER_BRANCH = "master"

/**
 * The result string for a successful build
 */
def BUILD_SUCCESS = 'SUCCESS'

/**
 * The result string for an unstable build
 */
def BUILD_UNSTABLE = 'UNSTABLE'

/**
 * The result string for a failed build
 */
def BUILD_FAILURE = 'FAILURE'

/**
 * The user's name for git commits
 */
def GIT_USER_NAME = 'zowe-robot'

/**
 * The user's email address for git commits
 */
def GIT_USER_EMAIL = 'zowe.robot@gmail.com'

/**
 * The base repository url for github
 */
def GIT_REPO_URL = 'https://github.com/zowe/api-layer.git'

/**
 * The credentials id field for the authorization token for GitHub stored in Jenkins
 */
def GIT_CREDENTIALS_ID = 'zowe-robot-github'

/**
 * A command to be run that gets the current revision pulled down
 */
def GIT_REVISION_LOOKUP = 'git log -n 1 --pretty=format:%h'

/**
 * The credentials id field for the artifactory username and password
 */
def ARTIFACTORY_CREDENTIALS_ID = 'zowe.jfrog.io'

/**
 * The email address for the artifactory
 */
def ARTIFACTORY_EMAIL = GIT_USER_EMAIL

// Setup conditional build options. Would have done this in the options of the declarative pipeline, but it is pretty
// much impossible to have conditional options based on the branch :/
def opts = []

if (BRANCH_NAME == MASTER_BRANCH) {
    // Only keep 20 builds
    opts.push(buildDiscarder(logRotator(numToKeepStr: '20')))

    // Concurrent builds need to be disabled on the master branch because
    // it needs to actively commit and do a build. There's no point in publishing
    // twice in quick succession
    opts.push(disableConcurrentBuilds())
} else {
    // Only keep 5 builds on other branches
    opts.push(buildDiscarder(logRotator(numToKeepStr: '5')))
}
properties(opts)

pipeline {
    agent {
        label 'ibm-jenkins-slave-nvm'
    }

    options {
        timestamps ()
    }

    stages {
        stage ('Install') {
            steps {
                sh 'npm install -g pnpm@4.0'
                sh 'npm install'
                sh 'cd api-catalog-ui/frontend && pnpm install'
            }
        }

        stage('Clean') {
            steps {
                sh './gradlew --info --scan clean'
            }
        }

        stage('Build') {
            steps {
                sh './gradlew --info --scan build'
            }
        }

        stage('liteLibJarAll') {
            steps {
                sh './gradlew --info --scan liteLibJarAll'
            }
        }

        stage('Integration Tests') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    sh './gradlew --info --scan runCITests runCITestsInternalPort -Penabler=v1 -DexternalJenkinsToggle="true" -Dcredentials.user=USER -Dcredentials.password=validPassword -Dzosmf.host=localhost -Dzosmf.port=10013 -Dzosmf.serviceId=mockzosmf -Dinternal.gateway.port=10017'
                }
            }
        }

        stage('Publish coverage reports') {
            steps {
                publishHTML(target: [
                    allowMissing         : false,
                    alwaysLinkToLastBuild: false,
                    keepAll              : true,
                    reportDir            : 'build/reports/jacoco/jacocoFullReport/html',
                    reportFiles          : 'index.html',
                    reportName           : "Java Coverage Report"
                ])
                    publishHTML(target: [
                        allowMissing         : false,
                        alwaysLinkToLastBuild: false,
                        keepAll              : true,
                        reportDir            : 'api-catalog-ui/frontend/coverage/lcov-report',
                        reportFiles          : 'index.html',
                        reportName           : "UI JavaScript Test Coverage"
                    ])
            }
        }

        stage('Package api-layer source code') {
            steps {
                sh "git archive --format tar.gz -9 --output api-layer.tar.gz HEAD"
            }
        }

        stage('Publish snapshot version to Artifactory for master') {
            when {
                expression {
                    return BRANCH_NAME.equals(MASTER_BRANCH);
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    ./gradlew publishAllVersions -Pzowe.deploy.username=$USERNAME -Pzowe.deploy.password=$PASSWORD -Partifactory_user=$USERNAME -Partifactory_password=$PASSWORD
                    '''
                }
            }
        }

        stage('Publish snapshot version to Artifactory for Pull Request') {
            when {
                expression {
                    return BRANCH_NAME.contains("PR-") && params.PUBLISH_PR_ARTIFACTS;
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    sed -i '/version=/ s/-SNAPSHOT/-'"$BRANCH_NAME"'-SNAPSHOT/' ./gradle.properties
                    ./gradlew publishAllVersions -Pzowe.deploy.username=$USERNAME -Pzowe.deploy.password=$PASSWORD  -Partifactory_user=$USERNAME -Partifactory_password=$PASSWORD -PpullRequest=$env.BRANCH_NAME
                    '''
                }
            }
        }

        stage('Publish UI test results') {
            steps {
                publishHTML(target: [
                    allowMissing         : false,
                    alwaysLinkToLastBuild: false,
                    keepAll              : true,
                    reportDir            : 'api-catalog-ui/frontend/test-results',
                    reportFiles          : 'test-report-unit.html',
                    reportName           : "UI Unit Test Results"
                ])
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: '**/test-results/**/*.xml'
            publishHTML (target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'gateway-service/build/reports/tests/test',
                reportFiles: 'index.html',
                reportName: "Unit Tests Report - gateway-service"
            ])
            publishHTML (target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'discovery-service/build/reports/tests/test',
                reportFiles: 'index.html',
                reportName: "Unit Tests Report - discovery-service"
            ])
            publishHTML (target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'api-catalog-services/build/reports/tests/test',
                reportFiles: 'index.html',
                reportName: "Unit Tests Report - api-catalog-services"
            ])

            archiveArtifacts artifacts: 'api-layer.tar.gz', allowEmptyArchive: true
        }
    }
}
