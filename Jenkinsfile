pipeline {
    agent any

    environment {
        MSYS2_BASH = 'C:\\msys64\\usr\\bin\\bash.exe'
        MSYS2_PATH = '/ucrt64/bin:/usr/bin'
        RUN_DIR = "04-cicd-docker/runs/jenkins-${BUILD_NUMBER}"
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Validate') {
            steps {
                bat '"%MSYS2_BASH%" -lc "export PATH=%MSYS2_PATH%:$PATH; bash 04-cicd-docker/scripts/validate.sh"'
            }
        }

        stage('Build') {
            steps {
                bat '"%MSYS2_BASH%" -lc "export PATH=%MSYS2_PATH%:$PATH; mkdir -p $RUN_DIR; bash 04-cicd-docker/scripts/build.sh $RUN_DIR"'
            }
        }

        stage('Test') {
            steps {
                bat '"%MSYS2_BASH%" -lc "export PATH=%MSYS2_PATH%:$PATH; bash 04-cicd-docker/scripts/test.sh $RUN_DIR"'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "${RUN_DIR}/**", allowEmptyArchive: true
        }
    }
}
