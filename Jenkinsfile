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
        stage("Deploy to EKS") {
    steps {
        withAWS(credentials: "${awscreds}", region: "${region}") {
            sh '''
                docker run --rm \
                  -v $(pwd):/workspace -w /workspace \
                  -v ~/.kube:/root/.kube \
                  -e AWS_ACCESS_KEY_ID \
                  -e AWS_SECRET_ACCESS_KEY \
                  -e AWS_DEFAULT_REGION=us-east-1 \
                  alpine/helm:3.14.3 \
                  sh -c "
                    aws eks update-kubeconfig --region us-east-1 --name nginx-cluster &&
                    helm upgrade --install nginx-app . \
                      --namespace production \
                      --create-namespace \
                      --set image.repository=187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx \
                      --set image.tag=latest
                  "
            '''
        }
    }
}


        stage ('verigy deployment') {
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
