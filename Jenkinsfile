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
              docker run --rm \
                -e AWS_ACCESS_KEY_ID \
                -e AWS_SECRET_ACCESS_KEY \
                -e AWS_SESSION_TOKEN \
                -e AWS_DEFAULT_REGION=us-east-1 \
                -v /var/jenkins_home/.kube:/root/.kube \
                -v /var/jenkins_home/workspace/eks-nginx-deploy/nginx-helm:/charts/nginx-helm \
                alpine/helm:3.14.0 \
                sh -c "
                  apk add --no-cache aws-cli &&
                  aws eks update-kubeconfig --region us-east-1 --name nginx-cluster &&
                  helm upgrade --install nginx-app /charts/nginx-helm \
                    --namespace production \
                    --create-namespace \
                    --set image.repository=187868012081.dkr.ecr.us-east-1.amazonaws.com/nginx \
                    --set image.tag=latest
                "
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
