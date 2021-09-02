pipeline {
    
  agent {
      label 'worker-01'
  }

  parameters {
    string defaultValue: 'master', description: 'This is the branch to checkout the code', name: 'branch_name'
    choice choices: ['DEV', 'SIT', 'UAT'], description: 'Environment to be deployed', name: 'environment'
  }

  triggers {
    cron '00 20 * * *'
  }

  options {
    disableConcurrentBuilds()
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')
    timestamps()
  }
  
  tools {
    jdk 'JAVA8'
    maven 'MAVEN3'
  }

  environment {
    data_path = "/opt/data/"
    SCANNER_HOME = tool 'sonarqube-scanner'
  }


stages {
  stage('Code Checkout') {
    steps {
      git branch: '$branch_name', credentialsId: 'github-credentials', url: 'https://github.com/gopishank/PetClinic.git'
    }
  }

  stage('Tests & Scans') {
      parallel {
          stage('Unit Testing'){
              steps {
                  sh "mvn test"
              }
          }
          stage('SonarQube Testing'){
              steps {
                  withSonarQubeEnv(installationName: 'sonarqube-server') {
                      sh "$SCANNER_HOME/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
                  }
              }
          }
      }
  }
  
  stage('Package Code'){
      steps {
          sh "mvn package -Dmaven.test.skip=true"
      }
  }
  
  stage('Upload Artifacts'){
      steps {
          sh '''
          curl -u admin:admin123 POST "http://ec2-3-237-98-114.compute-1.amazonaws.com:8081/service/rest/v1/components?repository=petclinic" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "maven2.groupId=org.springframework.samples" -F "maven2.artifactId=petclinic" -F "maven2.version=${BUILD_ID}.0.0" -F "maven2.asset1=@${WORKSPACE}/target/petclinic.war" -F "maven2.asset1.extension=war"
          '''
      }
  }
  
  stage('Code Deploy'){
      steps {
          ansiblePlaybook installation: 'ANSIBLE29', playbook: '/opt/ansible/deploy.yaml'
      }
  }

}


post {
  always {
    echo "Always Runs the code"
  }
  success {
    echo "Only runs when its successful"
  }
  failure {
    echo "Only runs when the Job has failed"
  }
}
}
