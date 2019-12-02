pipeline {

  agent any

  stages {

    stage ('Stage 1: Get Latest Code') {
      steps {
        step([$class: 'WsCleanup'])
        checkout scm
      }
    }

    stage ('Stage 2: Setup Python Virtual Environment') {
      steps {
        sh '''
          pip3.6 install --user -I virtualenv
          /usr/local/bin/virtualenv virtenv
          source virtenv/bin/activate
          pip install --upgrade molecule docker
        '''
      }
    }

    stage ('Stage 3: Display Versions') {
      steps {
        sh '''
          source virtenv/bin/activate
          docker -v
          python -V
          ansible --version
          molecule --version
        '''
      }
    }

    stage ('Stage 4: Molecule Tests') {
      stages {
        stage ('Stage 4.1: Test Common Role') {
          steps {
            sh '''
              source virtenv/bin/activate
              pushd roles/common
              molecule test
              popd
              deactivate
            '''
          }
        }
        stage ('Stage 4.2: Test Reverse Proxy Role') {
          steps {
            sh '''
              source virtenv/bin/activate
              pushd roles/reverse_proxy
              molecule test
              popd
              deactivate
            '''
          }
        }
        stage ('Stage 4.3: Test Web Server Role') {
          steps {
            sh '''
              source virtenv/bin/activate
              pushd roles/webserver
              molecule test
              popd
              deactivate
            '''
          }
        }
      }
    }

    stage ('Stage 5: Deployment') {
      stages {
        stage("Deploy into TEST Environment") {
          when {
            branch 'next'
          }
          steps {
            sh '''
              cd deployment
              ./deploy.sh
              cd ../
            '''
          }
        }
        stage("Deploy into PROD Environment") {
          when {
            branch 'master'
          }
          steps {
            sh '''
              cd deployment
              ./deploy.sh
              cd ../
            '''
          }
        }
      }
    }
  }
}
