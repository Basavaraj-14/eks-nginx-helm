pipeline {
    agent any
    environment {
            region = 'us-east-1'
            image = '187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx'
            awscreds = 'awscreds'
            cluster = 'nginx-cluster'
            tag = 'latest'

    }
    stages {
        stage("checkout code")
        {
            steps {
                checkout scm
            }
        }
        stage("buid image") {
            steps {
               sh 'docker build -t ${image}:${tag} .'
            }
        }
        stage("Push image") {
    steps {
        withAWS(credentials: "${awscreds}", region: "${region}") {
            sh '''
                docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
                  amazon/aws-cli:latest ecr get-login-password --region us-east-1 | \
                  docker login --username AWS --password-stdin \
                  187868012081.dkr.ecr.us-east-1.amazonaws.com && \
                docker push 187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx:latest
            '''
        }
    }
}
        stage('Deploy') {
            steps {
                sh '''
                    kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
                    kubectl run nginx-app --image=187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx:latest \
                      --port=80 --namespace=production --restart=Never --dry-run=client -o yaml | kubectl apply -f -
                    kubectl expose pod nginx-app --type=LoadBalancer --port=80 --namespace=production --dry-run=client -o yaml | kubectl apply -f -
                    kubectl get svc nginx-app -n production
                '''
            }
        }

        stage ('verify deployment') {
            steps {
                withAWS(credentials: "$awscreds", region: "$region") {
                    sh '''
                        kubectl get svc -n production 
                        kubectl get pods -n production '''
                }
            }
        }
    }
}
post {
    always {
        echo "pipeline completed"
    }
    failure {
        echo "pipeline failed"
    }
    success {
        echo "pipeline succeeded"
    }
}
