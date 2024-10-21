pipeline {
    agent any
    environment {
        GCLOUD_CREDENTIALS_PATH = 'gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json'
        PROJECT_ID = 'black-outlet-438804-p8'
        REGION = 'us-central1-a'
        CLUSTER_NAME = 'my-cluster'
    }
    
    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    // Install Terraform and Google Cloud SDK if needed
                    sh '''
                    if ! command -v terraform >/dev/null 2>&1; then
                      echo "Terraform not found, installing..."
                      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                      sudo apt-get update && sudo apt-get install terraform
                    fi

                    if ! command -v gcloud >/dev/null 2>&1; then
                      echo "gcloud CLI not found, installing..."
                      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
                      sudo apt-get install -y apt-transport-https ca-certificates gnupg
                      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
                      sudo apt-get update && sudo apt-get install google-cloud-sdk
                    fi
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
