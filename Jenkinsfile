
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/akshit-patel23/hello-gke.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t gcr.io/playground-s-11-06177195/hello-html:latest .'
            }
        }
        stage('Push to GCR') {
            steps {
                sh 'docker push gcr.io/playground-s-11-06177195/hello-html:latest'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
                sh 'kubectl apply -f k8s/hpa.yaml'
            }
        }
    }
}

