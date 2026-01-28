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
                      aws ecr get-login-password --region $region \
                      | docker login --username AWS --password-stdin 187868012081.dkr.ecr.us-east-1.amazonaws.com

                      docker push ${image}:${tag}
                    '''
                }
            }
        }

        stage("Deploy to EKS using Helm") {
            steps {
                withAWS(credentials: awscreds, region: region) {
                    sh '''
                      aws eks update-kubeconfig --region $region --name $cluster

                      helm upgrade --install nginx-app ./nginx-helm \
                        --namespace production \
                        --create-namespace \
                        --set image.repository=${image} \
                        --set image.tag=${tag}
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
