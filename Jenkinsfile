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
        stage ("push image") {
            steps {
                withAWS(credentials: "$awscreds", region: "$region") {
                    sh '''
                        docker run --rm \
                          -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
                          -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
                          -e AWS_DEFAULT_REGION=us-east-1 \
                          amazon/aws-cli:latest \
                        aws ecr get-login-password --region $region | docker login --username AWS --password-stdin 187868012081.dkr.ecr.us-east-1.amazonaws.com
                        docker tag ${image}:${tag}
                        docker push ${image}:${tag} '''
                }
            }
        }
        stage ("deploy to eks") {
            steps {
                withAWS(credentials: "$awscreds", region: "$region") {
                    sh '''
                        aws eks update-kubeconfig --region $region --name $cluster \
                        helm upgrade --install nginx-app . --namespace production --create-namespace \
                        --set image.repository=$image \
                        --set image.tag=$tag '''
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
