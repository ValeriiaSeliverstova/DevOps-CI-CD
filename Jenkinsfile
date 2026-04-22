pipeline {
  agent {
    kubernetes {
      defaultContainer 'git'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins/label: django-kaniko
spec:
  serviceAccountName: jenkins-agent
  containers:
    - name: git
      image: alpine/git:2.47.2
      command:
        - cat
      tty: true
    - name: python
      image: python:3.12-alpine
      command:
        - cat
      tty: true
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command:
        - /busybox/cat
      tty: true
      env:
        - name: AWS_SDK_LOAD_CONFIG
          value: "true"
        - name: AWS_DEFAULT_REGION
          value: "us-west-2"
"""
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }

  parameters {
    string(name: 'AWS_REGION', defaultValue: 'us-west-2', description: 'AWS region for ECR')
    string(name: 'ECR_REGISTRY', defaultValue: '143536904714.dkr.ecr.us-west-2.amazonaws.com', description: 'AWS ECR registry host')
    string(name: 'ECR_REPOSITORY', defaultValue: 'goit-ecr', description: 'AWS ECR repository name')
    string(name: 'GITOPS_REPO_URL', defaultValue: 'https://github.com/ValeriiaSeliverstova/DevOps-CI-CD-gitops.git', description: 'GitOps repository monitored by Argo CD')
    string(name: 'GITOPS_VALUES_FILE', defaultValue: 'helm/django-chart/values.yaml', description: 'Path to values.yaml inside the GitOps repository')
    string(name: 'GITOPS_BRANCH', defaultValue: 'main', description: 'GitOps branch to update')
    string(name: 'IMAGE_REPOSITORY_KEY', defaultValue: 'repository', description: 'Key inside image block for the repository value')
    string(name: 'IMAGE_TAG_KEY', defaultValue: 'tag', description: 'Key inside image block for the tag value')
  }

  environment {
    IMAGE_NAME = "${params.ECR_REGISTRY}/${params.ECR_REPOSITORY}"
  }

  stages {
    stage('Checkout') {
      steps {
        container('git') {
          sh 'git config --global --add safe.directory "${WORKSPACE}"'
          checkout scm
          script {
            env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
            env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
          }
        }
      }
    }

    stage('Build and Push to ECR') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context "${WORKSPACE}/docker/django" \
              --dockerfile "${WORKSPACE}/docker/django/Dockerfile" \
              --destination "${IMAGE_NAME}:${IMAGE_TAG}" \
              --destination "${IMAGE_NAME}:latest" \
              --snapshot-mode=redo \
              --use-new-run
          """
        }
      }
    }

    stage('Update GitOps Repository') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'gitops-repo-creds', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
          script {
            env.GITOPS_REPO_URL_WITHOUT_PROTOCOL = params.GITOPS_REPO_URL.replaceFirst('https?://', '')
          }

          container('git') {
            sh """
              git config --global user.name "jenkins"
              git config --global user.email "jenkins@local"
              git clone --branch "${params.GITOPS_BRANCH}" "https://${GIT_USERNAME}:${GIT_PASSWORD}@${GITOPS_REPO_URL_WITHOUT_PROTOCOL}" gitops-repo
            """
          }

          container('python') {
            sh """
              python - <<'PY'
import pathlib
import re

values_file = pathlib.Path("${WORKSPACE}") / "gitops-repo" / "${params.GITOPS_VALUES_FILE}"
content = values_file.read_text()

repo_key = "${params.IMAGE_REPOSITORY_KEY}"
tag_key = "${params.IMAGE_TAG_KEY}"
image_name = "${IMAGE_NAME}"
image_tag = "${IMAGE_TAG}"

image_block_pattern = re.compile(r'(^image:\\s*\\n(?:^[ \\t].*\\n?)*)', re.MULTILINE)
match = image_block_pattern.search(content)
if not match:
    raise SystemExit(f"image block not found in {values_file}")

block = match.group(1)
block = re.sub(rf'(^[ \\t]+{re.escape(repo_key)}:\\s*).*\$',
               rf'\\g<1>{image_name}',
               block,
               count=1,
               flags=re.MULTILINE)
block = re.sub(rf'(^[ \\t]+{re.escape(tag_key)}:\\s*).*\$',
               rf'\\g<1>{image_tag}',
               block,
               count=1,
               flags=re.MULTILINE)

updated = content[:match.start(1)] + block + content[match.end(1):]
values_file.write_text(updated)
PY
            """
          }

          container('git') {
            sh """
              cd gitops-repo
              git add "${params.GITOPS_VALUES_FILE}"
              if git diff --cached --quiet; then
                echo "GitOps repo already has the desired image tag"
                exit 0
              fi
              git commit -m "ci: update Django image to ${IMAGE_TAG}"
              git push origin "${params.GITOPS_BRANCH}"
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo "Pushed ${IMAGE_NAME}:${IMAGE_TAG} and updated ${params.GITOPS_VALUES_FILE}"
    }
  }
}
