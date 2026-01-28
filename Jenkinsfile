pipeline {
    // add your slave label name
    agent { label 'My-First-Jenkins-Slave-Server'}
    tools{
        maven 'Maven-Test'
    }
    stages {
        stage ('Checkout_SCM') {

            steps {
          	    
	     checkout scm
            }
        }

        stage ('Maven_Build') {

            steps {
               sh 'mvn clean package'
            }
        }
        
        stage ('Deploy_Tomcat') {

            steps {
	      sshagent(['My-Tomcat-Server']) {
              sh "scp -o StrictHostKeyChecking=no  target/maven-web-application.war  ec2-user@16.171.226.246:/opt/tomcat9/webapps"
	      }
         }
        }
        
    }
}
