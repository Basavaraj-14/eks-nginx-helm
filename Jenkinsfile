pipeline {
    agent any

    environment {
        region   = 'us-east-1'
        image    = '187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx'
        tag      = 'latest'
        cluster  = 'nginx-cluster'
        awscreds = 'awscreds'
    }

    stages {

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                sh 'docker build -t ${image}:${tag} .'
            }
        }

        stage("Push to ECR") {
    steps {
        withAWS(credentials: awscreds, region: region) {
            sh '''
              docker run --rm \
                -e AWS_ACCESS_KEY_ID \
                -e AWS_SECRET_ACCESS_KEY \
                -e AWS_SESSION_TOKEN \
                amazon/aws-cli:latest \
                ecr get-login-password --region us-east-1 \
              | docker login --username AWS --password-stdin 187868012081.dkr.ecr.us-east-1.amazonaws.com

              docker push 187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx:latest
            '''
        }
    }
}


        stage("Deploy to EKS using Helm") {
    steps {
        withAWS(credentials: awscreds, region: region) {
            sh '''
              # Generate kubeconfig using AWS CLI container
              docker run --rm \
                -e AWS_ACCESS_KEY_ID \
                -e AWS_SECRET_ACCESS_KEY \
                -e AWS_SESSION_TOKEN \
                -v $HOME/.kube:/root/.kube \
                amazon/aws-cli:latest \
                eks update-kubeconfig --region us-east-1 --name nginx-cluster

              # Deploy using Helm (helm must exist on Jenkins)
              helm upgrade --install nginx-app ./nginx-helm \
                --namespace production \
                --create-namespace \
                --set image.repository=187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx \
                --set image.tag=latest
            '''
        }
    }
}


        stage("Verify") {
            steps {
                sh '''
                  kubectl get pods -n production
                  kubectl get svc -n production
                '''
            }
        }
    }

    post {
        success { echo "✅ Helm deployment successful" }
        failure { echo "❌ Pipeline failed" }
    }
}
