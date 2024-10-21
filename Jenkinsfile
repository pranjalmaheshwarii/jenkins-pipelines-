pipeline {
    agent any
    environment {
        GCLOUD_CREDENTIALS_PATH = 'gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json'
        PROJECT_ID = 'black-outlet-438804-p8'
        REGION = 'us-central1-a'
        CLUSTER_NAME = 'my-cluster'
    }
    
    stages {
        stage('Install Terraform') {
            steps {
                script {
                    // Download and install Terraform
                    sh '''
                    # Set Terraform version
                    TERRAFORM_VERSION=1.5.5
                    
                    # Download Terraform binary
                    curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
                    
                    # Unzip and move the binary to /usr/local/bin
                    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                    mv terraform /usr/local/bin/
                    chmod +x /usr/local/bin/terraform

                    # Verify Terraform installation
                    terraform -version
                    '''
                }
            }
        }

        stage('Install Google Cloud SDK') {
            steps {
                script {
                    // Install Google Cloud SDK
                    sh '''
                    curl -sSL https://sdk.cloud.google.com | bash
                    exec -l $SHELL
                    gcloud init
                    '''
                }
            }
        }
        
        stage('Authenticate with Google Cloud') {
            steps {
                script {
                    // Download the credentials from the GCS bucket and authenticate using Google Cloud SDK
                    sh '''
                    gsutil cp ${GCLOUD_CREDENTIALS_PATH} ./gcloud-auth.json
                    gcloud auth activate-service-account --key-file=gcloud-auth.json
                    gcloud config set project ${PROJECT_ID}
                    gcloud config set compute/region ${REGION}
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    sh '''
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run Terraform plan to preview changes
                    sh '''
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform changes to create the GKE cluster
                    sh '''
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Configure kubectl') {
            steps {
                script {
                    // Get credentials for the newly created Kubernetes cluster
                    sh '''
                    gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${REGION} --project ${PROJECT_ID}
                    '''
                }
            }
        }

        stage('Deploy Kubernetes Manifests') {
            steps {
                script {
                    // Apply the Kubernetes manifests
                    sh '''
                    kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            // Cleanup after the pipeline run
            sh '''
            rm -f gcloud-auth.json
            '''
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
