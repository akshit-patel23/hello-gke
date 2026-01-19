
pipeline {
  agent any

  environment {
    PROJECT_ID   = "playground-s-11-06177195"
    REGION       = "us-central1"
    REPO         = "hello-repo"
    IMAGE_NAME   = "hello-app"

    CLUSTER_NAME = "hello-gke"
    CLUSTER_ZONE = "us-central1-a"

    DEPLOYMENT   = "hello-web"
    CONTAINER    = "hello-web"

    IMAGE        = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}"
  }

  stages {

    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("GCloud Auth + Docker Login") {
      steps {
        withCredentials([file(credentialsId: 'gcp-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh """
            echo "🔐 Activating Service Account..."
            gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
            gcloud config set project ${PROJECT_ID}

            echo "🔐 Docker Auth with Artifact Registry..."
            gcloud auth configure-docker ${REGION}-docker.pkg.dev -q
          """
        }
      }
    }

    stage("Docker Build & Push") {
      steps {
        sh """
          echo "🐳 Building Docker Image: ${IMAGE}:${BUILD_NUMBER}"

          docker build -t ${IMAGE}:${BUILD_NUMBER} .

          echo "📤 Pushing Image to Artifact Registry..."
          docker push ${IMAGE}:${BUILD_NUMBER}
        """
      }
    }

    stage("Get GKE Credentials") {
      steps {
        sh """
          echo "🔗 Fetching GKE Cluster Credentials..."
          gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE}
        """
      }
    }

    stage("Deploy to GKE") {
      steps {
        sh """
          echo "🚀 Applying K8s Manifests..."
          kubectl apply -f k8s/service.yaml
          kubectl apply -f k8s/deployment.yaml

          echo "🔄 Updating Deployment Image..."
          kubectl set image deployment/${DEPLOYMENT} ${CONTAINER}=${IMAGE}:${BUILD_NUMBER}

          echo "⌛ Waiting for Rollout..."
          kubectl rollout status deployment/${DEPLOYMENT}
        """
      }
    }

    stage("Apply HPA") {
      steps {
        sh """
          echo "📈 Applying HPA..."
          kubectl apply -f k8s/hpa.yaml
          kubectl get hpa
        """
      }
    }
  }

  post {
    success {
      sh '''
        echo "🎉 SUCCESS! App deployed with Docker-built image."
        echo -n "🌐 External IP: "
        kubectl get svc hello-web -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
        echo ""
      '''
    }
    failure {
      echo "❌ Pipeline Failed. Check logs."
    }
  }
}
