pipeline {
    agent any

    environment {
        // Set the environment variables
        GOOGLE_APPLICATION_CREDENTIALS = 'gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json'
        PROJECT_ID = 'black-outlet-438804-p8'
        CLUSTER_NAME = 'my-cluster'
        REGION = 'us-central1-a'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout your Terraform code from the specified repository
                git 'https://github.com/pranjalmaheshwarii/jenkins-pipelines-.git'
            }
        }

        stage('Download Service Account Key') {
            steps {
                script {
                    // Use gsutil to copy the service account key from GCS to the workspace
                    sh 'gsutil cp gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json ./service-account-key.json'
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }

        stage('Plan Terraform') {
            steps {
                script {
                    // Set the necessary environment variables for GCP authentication
                    withEnv(["GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json"]) {
                        // Plan the Terraform deployment
                        sh 'terraform plan -var "project_id=${PROJECT_ID}" -var "cluster_name=${CLUSTER_NAME}" -var "region=${REGION}"'
                    }
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    // Apply the Terraform plan
                    withEnv(["GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json"]) {
                        sh 'terraform apply -auto-approve -var "project_id=${PROJECT_ID}" -var "cluster_name=${CLUSTER_NAME}" -var "region=${REGION}"'
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
