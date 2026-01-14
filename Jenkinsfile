pipeline {
  agent any

  environment {
    PROJECT_ID   = "playground-s-11-06177195"
    REGION       = "us-central1"
    REPO         = "hello-repo"
    IMAGE_NAME   = "hello-app"

    CLUSTER_NAME = "hello-gke"
    CLUSTER_ZONE = "us-central1-a"

    DEPLOYMENT   = "hello-deployment"
    CONTAINER    = "hello-container"

    // Artifact Registry full image path
    IMAGE = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}"
  }

  stages {

    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Build & Push (Cloud Build)") {
      steps {
        sh """
          echo "Building image: ${IMAGE}:${BUILD_NUMBER}"

          gcloud config set project ${PROJECT_ID}

          # Build & push using Cloud Build (no docker needed on Jenkins VM)
          gcloud builds submit --tag ${IMAGE}:${BUILD_NUMBER} .
        """
      }
    }

    stage("Get GKE Credentials") {
      steps {
        sh """
          gcloud config set project ${PROJECT_ID}
          gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE}
        """
      }
    }

    stage("Deploy / Update K8s") {
      steps {
        sh """
          # Apply manifests (service, deployment, etc.)
          kubectl apply -f k8s/deployment.yml
          kubectl apply -f k8s/service.yml

          # Update deployment image to the new build
          kubectl set image deployment/${DEPLOYMENT} ${CONTAINER}=${IMAGE}:${BUILD_NUMBER}

          # Wait for rollout
          kubectl rollout status deployment/${DEPLOYMENT}
        """
      }
    }

    stage("Apply HPA") {
      steps {
        sh """
          kubectl apply -f k8s/hpa.yml
          kubectl get hpa
        """
      }
    }
  }

  post {
    success {
      echo "✅ CI/CD Success: Image deployed & HPA applied."
    }
    failure {
      echo "❌ CI/CD Failed. Check console output logs."
    }
  }
}