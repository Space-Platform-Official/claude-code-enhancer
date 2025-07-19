# CI/CD Integration with Claude Flow

This guide shows how to integrate Claude Flow with popular CI/CD platforms, ensuring code quality checks run automatically on every commit, pull request, and deployment.

## Overview

Claude Flow's CI/CD integration ensures:
- Automated code quality checks
- Consistent standards across teams
- Fast feedback on issues
- Protected main branches
- Automated deployments

## GitHub Actions

### Basic Setup

**`.github/workflows/claude-flow.yml`:**
```yaml
name: Claude Flow CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run Claude Flow validation
        run: |
          npm run lint
          npm run format:check
          npm run typecheck
          npm run test
      
      - name: Upload test coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Advanced Multi-Language Setup

**`.github/workflows/full-ci.yml`:**
```yaml
name: Full CI Pipeline

on:
  push:
    branches: [main, develop, 'release/*']
  pull_request:
    types: [opened, synchronize, reopened]

env:
  NODE_VERSION: 18
  PYTHON_VERSION: '3.11'
  GO_VERSION: '1.21'

jobs:
  # Detect what changed to run relevant jobs
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      services: ${{ steps.changes.outputs.services }}
      docs: ${{ steps.changes.outputs.docs }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'shared/**'
              - 'package-lock.json'
            backend:
              - 'backend/**'
              - 'shared/**'
              - 'requirements*.txt'
              - 'pyproject.toml'
            services:
              - 'services/**'
              - 'go.mod'
              - 'go.sum'
            docs:
              - 'docs/**'
              - '*.md'

  frontend:
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: frontend
        run: npm ci
      
      - name: Lint
        working-directory: frontend
        run: npm run lint
      
      - name: Type check
        working-directory: frontend
        run: npm run typecheck
      
      - name: Test
        working-directory: frontend
        run: npm run test:coverage
      
      - name: Build
        working-directory: frontend
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: frontend-build
          path: frontend/build/
          retention-days: 5
      
      - name: Lighthouse CI
        uses: treosh/lighthouse-ci-action@v9
        with:
          urls: |
            http://localhost:3000
          uploadArtifacts: true
          temporaryPublicStorage: true

  backend:
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        working-directory: backend
        run: |
          pip install -e ".[dev]"
      
      - name: Lint with flake8
        working-directory: backend
        run: flake8 app tests
      
      - name: Type check with mypy
        working-directory: backend
        run: mypy app
      
      - name: Test with pytest
        working-directory: backend
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        run: |
          pytest --cov=app --cov-report=xml --cov-report=html
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: backend/coverage.xml
          flags: backend

  services:
    needs: changes
    if: needs.changes.outputs.services == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ env.GO_VERSION }}
          cache: true
      
      - name: Download dependencies
        working-directory: services
        run: go mod download
      
      - name: Lint with golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          working-directory: services
      
      - name: Test
        working-directory: services
        run: go test -v -race -coverprofile=coverage.out ./...
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: services/coverage.out
          flags: services

  integration-tests:
    needs: [frontend, backend, services]
    if: always() && !contains(needs.*.result, 'failure')
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Download frontend build
        uses: actions/download-artifact@v3
        with:
          name: frontend-build
          path: frontend/build
      
      - name: Setup Docker Compose
        run: |
          docker-compose -f docker-compose.test.yml build
          docker-compose -f docker-compose.test.yml up -d
      
      - name: Wait for services
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:3000; do sleep 2; done'
          timeout 60 bash -c 'until curl -f http://localhost:8000/health; do sleep 2; done'
      
      - name: Run E2E tests
        run: |
          npm run test:e2e
      
      - name: Collect logs on failure
        if: failure()
        run: |
          docker-compose -f docker-compose.test.yml logs > compose-logs.txt
      
      - name: Upload logs
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-logs
          path: compose-logs.txt
      
      - name: Cleanup
        if: always()
        run: docker-compose -f docker-compose.test.yml down -v

  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: OWASP dependency check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'claude-flow-app'
          path: '.'
          format: 'HTML'
      
      - name: Upload dependency check results
        uses: actions/upload-artifact@v3
        with:
          name: dependency-check-report
          path: reports/

  deploy-preview:
    needs: [integration-tests, security-scan]
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel Preview
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./frontend
      
      - name: Comment PR with preview URL
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '🚀 Preview deployment ready!\n\nPreview: ${{ steps.vercel.outputs.preview-url }}'
            })

  deploy-production:
    needs: [integration-tests, security-scan]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to ECS
        run: |
          ./scripts/deploy-to-ecs.sh production
```

## GitLab CI/CD

**`.gitlab-ci.yml`:**
```yaml
stages:
  - validate
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "18"
  PYTHON_VERSION: "3.11"
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""

# Cache configuration
.node_cache: &node_cache
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - frontend/node_modules/
      - .npm/

.python_cache: &python_cache
  cache:
    key: ${CI_COMMIT_REF_SLUG}-python
    paths:
      - .cache/pip
      - backend/venv/

# Validation stage
lint:frontend:
  stage: validate
  image: node:${NODE_VERSION}
  <<: *node_cache
  before_script:
    - cd frontend
    - npm ci --cache .npm --prefer-offline
  script:
    - npm run lint
    - npm run format:check
  only:
    changes:
      - frontend/**/*
      - .gitlab-ci.yml

lint:backend:
  stage: validate
  image: python:${PYTHON_VERSION}
  <<: *python_cache
  before_script:
    - cd backend
    - pip install --cache-dir .cache/pip -e ".[dev]"
  script:
    - flake8 app tests
    - black --check app tests
    - mypy app
  only:
    changes:
      - backend/**/*
      - .gitlab-ci.yml

# Test stage
test:frontend:
  stage: test
  image: node:${NODE_VERSION}
  <<: *node_cache
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  before_script:
    - cd frontend
    - npm ci --cache .npm --prefer-offline
  script:
    - npm run test:coverage
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: frontend/coverage/cobertura-coverage.xml
      junit: frontend/junit.xml
  only:
    changes:
      - frontend/**/*
      - shared/**/*

test:backend:
  stage: test
  image: python:${PYTHON_VERSION}
  <<: *python_cache
  services:
    - postgres:15
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
  coverage: '/TOTAL.*\s+(\d+%)$/'
  before_script:
    - cd backend
    - pip install --cache-dir .cache/pip -e ".[dev]"
  script:
    - pytest --cov=app --cov-report=xml --cov-report=term
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: backend/coverage.xml
      junit: backend/report.xml

# Build stage
build:frontend:
  stage: build
  image: node:${NODE_VERSION}
  <<: *node_cache
  before_script:
    - cd frontend
    - npm ci --cache .npm --prefer-offline
  script:
    - npm run build
    - echo "Build size:"
    - du -sh build/
  artifacts:
    paths:
      - frontend/build/
    expire_in: 1 week
  only:
    - main
    - develop
    - /^release\/.*$/

build:docker:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA ./frontend
    - docker build -t $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA ./backend
    - docker push $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA
    # Tag as latest if on main
    - |
      if [ "$CI_COMMIT_BRANCH" == "main" ]; then
        docker tag $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE/frontend:latest
        docker tag $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE/backend:latest
        docker push $CI_REGISTRY_IMAGE/frontend:latest
        docker push $CI_REGISTRY_IMAGE/backend:latest
      fi
  only:
    - main
    - develop
    - /^release\/.*$/

# Deploy stage
deploy:staging:
  stage: deploy
  image: alpine:latest
  environment:
    name: staging
    url: https://staging.example.com
  before_script:
    - apk add --no-cache curl
  script:
    - echo "Deploying to staging..."
    - curl -X POST $DEPLOY_WEBHOOK_STAGING
  only:
    - develop

deploy:production:
  stage: deploy
  image: alpine:latest
  environment:
    name: production
    url: https://example.com
  before_script:
    - apk add --no-cache curl
  script:
    - echo "Deploying to production..."
    - curl -X POST $DEPLOY_WEBHOOK_PRODUCTION
  only:
    - main
  when: manual
```

## Jenkins Pipeline

**`Jenkinsfile`:**
```groovy
pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
        PYTHON_VERSION = '3.11'
        DOCKER_REGISTRY = 'registry.example.com'
        DOCKER_CREDENTIALS = credentials('docker-registry')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Validate') {
            parallel {
                stage('Frontend Lint') {
                    agent {
                        docker {
                            image "node:${NODE_VERSION}"
                            args '-v $HOME/.npm:/root/.npm'
                        }
                    }
                    steps {
                        dir('frontend') {
                            sh 'npm ci'
                            sh 'npm run lint'
                            sh 'npm run format:check'
                        }
                    }
                }
                
                stage('Backend Lint') {
                    agent {
                        docker {
                            image "python:${PYTHON_VERSION}"
                        }
                    }
                    steps {
                        dir('backend') {
                            sh 'pip install -e ".[dev]"'
                            sh 'flake8 app tests'
                            sh 'black --check app tests'
                            sh 'mypy app'
                        }
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Frontend Tests') {
                    agent {
                        docker {
                            image "node:${NODE_VERSION}"
                            args '-v $HOME/.npm:/root/.npm'
                        }
                    }
                    steps {
                        dir('frontend') {
                            sh 'npm ci'
                            sh 'npm run test:coverage'
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'frontend/coverage/lcov-report',
                                reportFiles: 'index.html',
                                reportName: 'Frontend Coverage'
                            ])
                        }
                    }
                }
                
                stage('Backend Tests') {
                    agent {
                        docker {
                            image "python:${PYTHON_VERSION}"
                            args '--network="host"'
                        }
                    }
                    steps {
                        script {
                            docker.image('postgres:15').withRun(
                                '-e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=test_db'
                            ) { c ->
                                dir('backend') {
                                    sh 'pip install -e ".[dev]"'
                                    sh 'DATABASE_URL=postgresql://postgres:postgres@localhost:5432/test_db pytest --cov=app --cov-report=html'
                                }
                            }
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'backend/htmlcov',
                                reportFiles: 'index.html',
                                reportName: 'Backend Coverage'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch pattern: "release/.*", comparator: "REGEXP"
                }
            }
            steps {
                script {
                    // Build frontend
                    docker.build(
                        "${DOCKER_REGISTRY}/frontend:${GIT_COMMIT_SHORT}",
                        "./frontend"
                    )
                    
                    // Build backend
                    docker.build(
                        "${DOCKER_REGISTRY}/backend:${GIT_COMMIT_SHORT}",
                        "./backend"
                    )
                }
            }
        }
        
        stage('Push') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image("${DOCKER_REGISTRY}/frontend:${GIT_COMMIT_SHORT}").push()
                        docker.image("${DOCKER_REGISTRY}/backend:${GIT_COMMIT_SHORT}").push()
                        
                        if (env.BRANCH_NAME == 'main') {
                            docker.image("${DOCKER_REGISTRY}/frontend:${GIT_COMMIT_SHORT}").push('latest')
                            docker.image("${DOCKER_REGISTRY}/backend:${GIT_COMMIT_SHORT}").push('latest')
                        }
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                
                script {
                    // Deploy using kubectl or your deployment tool
                    sh './scripts/deploy.sh production'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: "✅ Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## CircleCI

**`.circleci/config.yml`:**
```yaml
version: 2.1

orbs:
  node: circleci/node@5.0
  python: circleci/python@2.0
  docker: circleci/docker@2.0
  aws-cli: circleci/aws-cli@3.0

executors:
  node-executor:
    docker:
      - image: cimg/node:18.0
  python-executor:
    docker:
      - image: cimg/python:3.11

workflows:
  main:
    jobs:
      - frontend-test
      - backend-test
      - security-scan
      - build:
          requires:
            - frontend-test
            - backend-test
          filters:
            branches:
              only:
                - main
                - develop
      - deploy-staging:
          requires:
            - build
            - security-scan
          filters:
            branches:
              only: develop
      - hold-production:
          type: approval
          requires:
            - build
            - security-scan
          filters:
            branches:
              only: main
      - deploy-production:
          requires:
            - hold-production
          filters:
            branches:
              only: main

jobs:
  frontend-test:
    executor: node-executor
    steps:
      - checkout
      - node/install-packages:
          pkg-manager: npm
          app-dir: frontend
      - run:
          name: Lint
          command: |
            cd frontend
            npm run lint
      - run:
          name: Type Check
          command: |
            cd frontend
            npm run typecheck
      - run:
          name: Test
          command: |
            cd frontend
            npm run test:coverage
      - store_test_results:
          path: frontend/test-results
      - store_artifacts:
          path: frontend/coverage

  backend-test:
    executor: python-executor
    docker:
      - image: cimg/python:3.11
      - image: cimg/postgres:15.0
        environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
    steps:
      - checkout
      - python/install-packages:
          pkg-manager: pip
          app-dir: backend
      - run:
          name: Lint
          command: |
            cd backend
            flake8 app tests
            black --check app tests
      - run:
          name: Type Check
          command: |
            cd backend
            mypy app
      - run:
          name: Test
          environment:
            DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
          command: |
            cd backend
            pytest --cov=app --cov-report=xml
      - store_test_results:
          path: backend/test-results
      - store_artifacts:
          path: backend/coverage.xml

  security-scan:
    docker:
      - image: aquasec/trivy:latest
    steps:
      - checkout
      - run:
          name: Scan for vulnerabilities
          command: |
            trivy fs --exit-code 1 --severity HIGH,CRITICAL .

  build:
    executor: docker/docker
    steps:
      - checkout
      - setup_remote_docker:
          docker_layer_caching: true
      - run:
          name: Build images
          command: |
            docker build -t app/frontend:$CIRCLE_SHA1 ./frontend
            docker build -t app/backend:$CIRCLE_SHA1 ./backend
      - run:
          name: Push to registry
          command: |
            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
            docker push app/frontend:$CIRCLE_SHA1
            docker push app/backend:$CIRCLE_SHA1

  deploy-staging:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup
      - run:
          name: Deploy to staging
          command: |
            ./scripts/deploy.sh staging $CIRCLE_SHA1

  deploy-production:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup
      - run:
          name: Deploy to production
          command: |
            ./scripts/deploy.sh production $CIRCLE_SHA1
```

## Bitbucket Pipelines

**`bitbucket-pipelines.yml`:**
```yaml
image: node:18

definitions:
  caches:
    npm: $HOME/.npm
    pip: $HOME/.cache/pip
  
  steps:
    - step: &frontend-test
        name: Frontend Test
        image: node:18
        caches:
          - npm
        script:
          - cd frontend
          - npm ci
          - npm run lint
          - npm run typecheck
          - npm run test:coverage
        artifacts:
          - frontend/coverage/**
    
    - step: &backend-test
        name: Backend Test
        image: python:3.11
        caches:
          - pip
        services:
          - postgres
        script:
          - cd backend
          - pip install -e ".[dev]"
          - flake8 app tests
          - mypy app
          - DATABASE_URL=postgresql://test:test@localhost:5432/test pytest --cov=app
    
    - step: &build-images
        name: Build Docker Images
        image: docker:latest
        services:
          - docker
        script:
          - docker build -t $DOCKER_REGISTRY/frontend:$BITBUCKET_COMMIT ./frontend
          - docker build -t $DOCKER_REGISTRY/backend:$BITBUCKET_COMMIT ./backend
          - echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
          - docker push $DOCKER_REGISTRY/frontend:$BITBUCKET_COMMIT
          - docker push $DOCKER_REGISTRY/backend:$BITBUCKET_COMMIT

pipelines:
  default:
    - parallel:
        - step: *frontend-test
        - step: *backend-test

  branches:
    main:
      - parallel:
          - step: *frontend-test
          - step: *backend-test
      - step: *build-images
      - step:
          name: Deploy to Production
          deployment: production
          script:
            - pipe: atlassian/aws-ecs-deploy:1.6.2
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: us-east-1
                CLUSTER_NAME: production
                SERVICE_NAME: app-service
                TASK_DEFINITION: task-definition.json

    develop:
      - parallel:
          - step: *frontend-test
          - step: *backend-test
      - step: *build-images
      - step:
          name: Deploy to Staging
          deployment: staging
          script:
            - ./scripts/deploy.sh staging $BITBUCKET_COMMIT

  pull-requests:
    '**':
      - parallel:
          - step: *frontend-test
          - step: *backend-test
      - step:
            name: Security Scan
            script:
              - pipe: aquasecurity/trivy:1.0.0
                variables:
                  SEVERITY: "HIGH,CRITICAL"

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
```

## Best Practices

### 1. Fail Fast
```yaml
# Run quick checks first
stages:
  - quick-checks  # Linting, formatting
  - tests         # Unit tests
  - integration   # Slower integration tests
  - build         # Only if tests pass
```

### 2. Parallel Execution
```yaml
# Run independent jobs in parallel
test:
  parallel:
    - frontend-unit
    - backend-unit
    - lint-checks
```

### 3. Caching Dependencies
```yaml
# Cache node_modules, pip packages, etc.
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/
    - .cache/pip/
```

### 4. Environment-Specific Deployments
```yaml
# Different configs for different environments
deploy:staging:
  variables:
    API_URL: https://api.staging.example.com
    
deploy:production:
  variables:
    API_URL: https://api.example.com
  when: manual  # Require manual approval
```

### 5. Secret Management
```bash
# Use CI/CD platform's secret management
# GitHub: Settings > Secrets
# GitLab: Settings > CI/CD > Variables
# CircleCI: Project Settings > Environment Variables
```

### 6. Build Matrix
```yaml
# Test against multiple versions
strategy:
  matrix:
    node: [16, 18, 20]
    python: [3.9, 3.10, 3.11]
```

## Monitoring CI/CD

### Status Badges
```markdown
# README.md
![CI Status](https://github.com/user/repo/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)
![Security](https://snyk.io/test/github/user/repo/badge.svg)
```

### Notifications
```yaml
# Slack notifications
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build failed! Check the logs.'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Performance Tracking
```yaml
# Track build times
- name: Report Build Time
  run: |
    echo "Build completed in $((SECONDS / 60)) minutes"
```

## Troubleshooting

### Common Issues

1. **Flaky Tests**
```yaml
# Retry flaky tests
retry:
  max: 2
  when:
    - unknown_failure
    - api_failure
```

2. **Out of Memory**
```yaml
# Increase Node memory
env:
  NODE_OPTIONS: "--max-old-space-size=4096"
```

3. **Slow Builds**
```yaml
# Use build caching
- uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      ~/.cache
    key: ${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
```

## Enterprise CI/CD Patterns

<details>
<summary>🏢 Enterprise-Grade Pipeline Configurations</summary>

### Advanced Security Integration

**Supply Chain Security:**
```yaml
# .github/workflows/security.yml
name: Security Checks

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  supply-chain:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: SLSA Builder
        uses: slsa-framework/slsa-github-generator/.github/workflows/builder_go_slsa3.yml@v1.5.0
        with:
          go-version: 1.21
      
      - name: Sigstore Cosign
        uses: sigstore/cosign-installer@v3
        with:
          cosign-release: 'v2.0.0'
      
      - name: Sign artifacts
        run: |
          cosign sign --yes ${{ env.REGISTRY }}/app:${{ github.sha }}
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          path: ./
          format: spdx-json
      
      - name: Scan with Grype
        uses: anchore/scan-action@v3
        with:
          path: "."
          fail-build: true
          severity-cutoff: high
```

**Zero-Trust Architecture:**
```yaml
# Multi-environment promotion with approval gates
deployment-pipeline:
  strategy:
    environments:
      - name: development
        auto_deploy: true
        required_reviewers: 0
      - name: staging
        auto_deploy: false
        required_reviewers: 1
        protection_rules:
          - required_status_checks: [security-scan, performance-test]
      - name: production
        auto_deploy: false
        required_reviewers: 2
        protection_rules:
          - required_status_checks: [staging-deployment-success]
          - restrict_pushes: true
          - required_conversation_resolution: true
```

### Multi-Cloud Deployment

**AWS + Azure + GCP:**
```yaml
# .github/workflows/multi-cloud.yml
multi-cloud-deploy:
  strategy:
    matrix:
      cloud:
        - provider: aws
          region: us-east-1
          service: ecs
        - provider: azure
          region: eastus
          service: container-instances
        - provider: gcp
          region: us-central1
          service: cloud-run
  
  steps:
    - name: Deploy to ${{ matrix.cloud.provider }}
      uses: ./.github/actions/deploy-${{ matrix.cloud.provider }}
      with:
        region: ${{ matrix.cloud.region }}
        service: ${{ matrix.cloud.service }}
        image: ${{ env.REGISTRY }}/app:${{ github.sha }}
```

</details>

<details>
<summary>🔄 Advanced Workflow Patterns</summary>

### Matrix Testing with Comprehensive Coverage

```yaml
# Complete matrix testing strategy
test-matrix:
  strategy:
    fail-fast: false
    matrix:
      include:
        # Frontend combinations
        - language: node
          version: 16
          os: ubuntu-latest
          browser: chrome
          env: development
        - language: node
          version: 18
          os: ubuntu-latest
          browser: firefox
          env: staging
        - language: node
          version: 20
          os: macos-latest
          browser: safari
          env: production
        
        # Backend combinations
        - language: python
          version: '3.9'
          os: ubuntu-latest
          database: postgresql
          cache: redis
        - language: python
          version: '3.11'
          os: ubuntu-latest
          database: mysql
          cache: memcached
        
        # Cross-platform testing
        - language: go
          version: '1.21'
          os: windows-latest
          arch: amd64
        - language: go
          version: '1.21'
          os: ubuntu-latest
          arch: arm64
```

### Conditional Pipeline Optimization

```yaml
# Smart pipeline execution based on changes
jobs:
  detect-changes:
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      infrastructure: ${{ steps.changes.outputs.infrastructure }}
      documentation: ${{ steps.changes.outputs.documentation }}
    
    steps:
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'shared/types/**'
            backend:
              - 'backend/**'
              - 'shared/types/**'
              - 'database/**'
            infrastructure:
              - 'terraform/**'
              - 'k8s/**'
              - 'docker/**'
            documentation:
              - 'docs/**'
              - '*.md'
              - '.github/**'
  
  # Conditional job execution
  frontend-tests:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    strategy:
      matrix:
        test-type: [unit, integration, e2e, visual-regression]
    steps:
      - name: Run ${{ matrix.test-type }} tests
        run: npm run test:${{ matrix.test-type }}
```

</details>

<details>
<summary>🚀 Performance and Optimization</summary>

### Build Optimization Strategies

**Intelligent Caching:**
```yaml
# Advanced caching strategy
- name: Cache build dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      ~/.cache/pip
      ~/.cargo/registry
      ~/.cargo/git
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json', '**/requirements.txt', '**/Cargo.lock', '**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-deps-

# Docker layer caching
- name: Setup Docker Buildx
  uses: docker/setup-buildx-action@v2
  with:
    driver-opts: |
      network=host
      image=moby/buildkit:buildx-stable-1
      
- name: Build with cache
  uses: docker/build-push-action@v4
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    cache-from: type=gha
    cache-to: type=gha,mode=max
    push: true
    tags: ${{ env.REGISTRY }}/app:${{ github.sha }}
```

**Parallel Job Execution:**
```yaml
# Maximized parallelization
stages:
  preparation:
    jobs: [checkout, cache-dependencies]
  
  validation:
    needs: preparation
    jobs: [lint-frontend, lint-backend, type-check, security-scan]
  
  testing:
    needs: validation
    jobs: [unit-tests, integration-tests, contract-tests]
  
  quality:
    needs: testing
    jobs: [coverage-report, sonar-analysis, performance-benchmark]
  
  build:
    needs: quality
    jobs: [build-frontend, build-backend, build-mobile]
  
  deploy:
    needs: build
    jobs: [deploy-staging, deploy-preview]
```

### Performance Monitoring Integration

```yaml
# Performance testing in CI
performance-tests:
  steps:
    - name: Lighthouse CI
      uses: treosh/lighthouse-ci-action@v9
      with:
        configPath: '.lighthouserc.json'
        uploadArtifacts: true
        temporaryPublicStorage: true
    
    - name: Web Vitals Monitoring
      run: |
        npm run test:performance
        npm run analyze:bundle-size
    
    - name: Load Testing with Artillery
      run: |
        npm install -g artillery
        artillery run load-test-config.yml
    
    - name: Performance Regression Check
      uses: benchmark-action/github-action-benchmark@v1
      with:
        tool: 'customSmallerIsBetter'
        output-file-path: performance-results.json
        github-token: ${{ secrets.GITHUB_TOKEN }}
        auto-push: true
        alert-threshold: '200%'
        comment-on-alert: true
```

</details>

## Advanced Troubleshooting Guide

<details>
<summary>🔧 Common CI/CD Issues and Solutions</summary>

### Build Failures

**Memory Issues:**
```yaml
# Increase Node.js memory for large builds
env:
  NODE_OPTIONS: "--max-old-space-size=8192"
  GRADLE_OPTS: "-Xmx4g -XX:MaxMetaspaceSize=1g"
  MAVEN_OPTS: "-Xmx3g"

# For GitHub Actions
runs-on: ubuntu-latest-8-cores  # Use larger runners
```

**Timeout Issues:**
```yaml
# Set appropriate timeouts
jobs:
  test:
    timeout-minutes: 30
    steps:
      - name: Run tests with timeout
        timeout-minutes: 20
        run: npm test
```

**Flaky Test Handling:**
```yaml
# Retry mechanism for flaky tests
- name: Run tests with retry
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_on: error
    command: npm test

# Quarantine flaky tests
- name: Run stable tests
  run: npm test -- --grep "^(?!.*flaky).*$"
  
- name: Run flaky tests separately
  continue-on-error: true
  run: npm test -- --grep "flaky"
```

### Dependency Issues

**Lock File Conflicts:**
```bash
# Clean dependency resolution
rm -rf node_modules package-lock.json
npm install
npm audit fix

# For Python
pip-compile --upgrade requirements.in
pip-sync

# For Go
go mod tidy
go mod verify
```

**Security Vulnerabilities:**
```yaml
# Automated security updates
- name: Security audit
  run: |
    npm audit --audit-level high
    pip safety check
    go list -json -m all | nancy sleuth

# Automated dependency updates
- name: Update dependencies
  uses: renovatebot/github-action@v34.100.0
  with:
    configurationFile: .github/renovate.json
    token: ${{ secrets.RENOVATE_TOKEN }}
```

### Environment-Specific Issues

**Cross-Platform Compatibility:**
```yaml
# Handle path differences
- name: Set paths (Unix)
  if: runner.os != 'Windows'
  run: echo "SCRIPT_PATH=./scripts/build.sh" >> $GITHUB_ENV
  
- name: Set paths (Windows)
  if: runner.os == 'Windows'
  run: echo "SCRIPT_PATH=.\scripts\build.bat" >> $GITHUB_ENV
  
- name: Run build script
  run: ${{ env.SCRIPT_PATH }}
```

</details>

<details>
<summary>🛡️ Security Best Practices</summary>

### Secrets Management

**Hierarchical Secrets:**
```yaml
# Environment-specific secrets
env:
  # Global secrets
  API_KEY: ${{ secrets.API_KEY }}
  
  # Environment-specific
  DATABASE_URL: ${{ 
    github.ref == 'refs/heads/main' && 
    secrets.PROD_DATABASE_URL || 
    secrets.STAGING_DATABASE_URL 
  }}
  
  # Feature flag secrets
  FEATURE_FLAGS: ${{ 
    contains(github.event.head_commit.message, '[enable-beta]') && 
    secrets.BETA_FEATURE_FLAGS || 
    secrets.DEFAULT_FEATURE_FLAGS 
  }}
```

**Secure Artifact Handling:**
```yaml
# Signed and encrypted artifacts
- name: Encrypt sensitive artifacts
  run: |
    gpg --symmetric --cipher-algo AES256 sensitive-config.json
    
- name: Upload encrypted artifacts
  uses: actions/upload-artifact@v3
  with:
    name: encrypted-config
    path: sensitive-config.json.gpg
    retention-days: 1
```

### RBAC and Permissions

**Minimal Permissions:**
```yaml
# Explicit permission grants
permissions:
  contents: read
  packages: write
  security-events: write
  actions: read
  checks: write
  statuses: write
  pull-requests: write

# Job-specific permissions
jobs:
  deploy:
    permissions:
      contents: read
      id-token: write  # For OIDC
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: GitHubActions
          aws-region: us-east-1
```

</details>

## Multi-Agent CI/CD Coordination

<details>
<summary>🤖 Claude Multi-Agent Integration</summary>

### AI-Driven Quality Checks

```yaml
# Claude-powered code review
- name: AI Code Review
  uses: ./.github/actions/claude-review
  with:
    files-changed: ${{ steps.changes.outputs.files }}
    review-depth: thorough
    focus-areas: |
      - Security vulnerabilities
      - Performance issues
      - Code quality
      - Test coverage gaps

# Automated fix suggestions
- name: Generate Fix Suggestions
  if: failure()
  run: |
    claude analyze-failures \
      --build-logs build.log \
      --test-results test-results.xml \
      --suggest-fixes
```

### Intelligent Pipeline Optimization

```yaml
# AI-driven pipeline optimization
- name: Optimize Pipeline
  uses: ./.github/actions/claude-optimize
  with:
    analyze-patterns: true
    optimize-for: speed
    historical-data-days: 30
    
# Dynamic test selection
- name: Smart Test Selection
  run: |
    claude select-tests \
      --changed-files "${{ steps.changes.outputs.files }}" \
      --test-history .test-history.json \
      --confidence-threshold 0.95
```

### Automated Documentation Updates

```yaml
# AI-generated documentation
- name: Update Documentation
  if: contains(github.event.head_commit.message, '[update-docs]')
  run: |
    claude generate-docs \
      --source-code src/ \
      --api-specs openapi.yaml \
      --output docs/ \
      --format markdown
    
    git add docs/
    git commit -m "docs: AI-generated documentation update"
    git push
```

</details>

## Monitoring and Observability

<details>
<summary>📊 Comprehensive Pipeline Monitoring</summary>

### Pipeline Metrics Collection

```yaml
# Detailed metrics collection
- name: Collect Pipeline Metrics
  run: |
    echo "build_duration_seconds ${{ steps.timer.outputs.duration }}" >> metrics.txt
    echo "test_count ${{ steps.test.outputs.test_count }}" >> metrics.txt
    echo "coverage_percentage ${{ steps.coverage.outputs.percentage }}" >> metrics.txt
    echo "artifact_size_mb ${{ steps.build.outputs.size_mb }}" >> metrics.txt

- name: Send Metrics to Datadog
  uses: masci/datadog@v1
  with:
    api-key: ${{ secrets.DATADOG_API_KEY }}
    metrics-file: metrics.txt

# Real-time notifications
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: custom
    custom_payload: |
      {
        attachments: [{
          color: '${{ job.status }}' === 'success' ? 'good' : 'danger',
          blocks: [{
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: `*${{ github.repository }}* - ${{ github.workflow }}\n*Status:* ${{ job.status }}\n*Duration:* ${{ steps.timer.outputs.duration }}s\n*Tests:* ${{ steps.test.outputs.test_count }} passed\n*Coverage:* ${{ steps.coverage.outputs.percentage }}%`
            }
          }]
        }]
      }
```

### Error Tracking and Analysis

```yaml
# Comprehensive error collection
- name: Collect Error Details
  if: failure()
  run: |
    # Capture system information
    echo "## System Info" >> error-report.md
    uname -a >> error-report.md
    echo "\n## Environment" >> error-report.md
    env | sort >> error-report.md
    
    # Capture build logs
    echo "\n## Build Logs" >> error-report.md
    tail -100 build.log >> error-report.md
    
    # Capture test failures
    if [ -f test-results.xml ]; then
      echo "\n## Test Failures" >> error-report.md
      grep -A 5 -B 5 "failure" test-results.xml >> error-report.md
    fi

- name: Send Error Report
  if: failure()
  uses: JasonEtco/create-an-issue@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    filename: .github/ISSUE_TEMPLATE/ci-failure.md
    update_existing: true
```

</details>

## Next Steps

- Explore [migration guide](./migration-guide.md) for existing projects
- Learn about [multi-language setups](./multi-language.md)
- Review [JavaScript project examples](./javascript-project.md)
- Check [Python project patterns](./python-project.md)
- Study [React application workflows](./react-app.md)