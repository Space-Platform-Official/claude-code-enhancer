# Multi-Language Project Setup with Claude Flow

This guide demonstrates how to set up and manage projects with multiple programming languages using Claude Flow, including shared configurations, cross-language testing, and unified CI/CD.

## Prerequisites

- Git initialized in your project
- Claude Flow installed globally
- Required language runtimes (Node.js, Python, Go, etc.)

## Common Multi-Language Scenarios

1. **Full-Stack Web App**: React frontend + Python backend
2. **Microservices**: Multiple services in different languages
3. **Data Pipeline**: Python scripts + Go services + Node.js API
4. **Mobile + Backend**: React Native + Java Spring + Node.js BFF

## Step-by-Step Setup

### 1. Initialize Multi-Language Project

```bash
# Create project structure
mkdir fullstack-app
cd fullstack-app

# Initialize Claude Flow
claude flow init --multi-language

# Or interactively:
claude flow init
# Select: Multi-language project
```

**Expected Output:**
```
🚀 Initializing Claude Flow for multi-language project...
✅ Created .claude directory
✅ Created CLAUDE.md with multi-language instructions
✅ Set up git hooks for all languages
✅ Created unified Makefile
✅ Created language-specific configurations

Detected languages will be configured as you add them.
```

### 2. Project Structure

```bash
# Create structure for full-stack app
claude create-structure --type fullstack

# Creates:
fullstack-app/
├── .claude/
│   ├── commands/
│   └── hooks/
├── frontend/           # React/TypeScript
├── backend/            # Python/FastAPI
├── shared/             # Shared types/contracts
├── scripts/            # Build and deployment scripts
├── docker/             # Container configurations
├── .github/
│   └── workflows/
├── Makefile           # Unified commands
├── docker-compose.yml
└── README.md
```

### 3. Configure Frontend (React/TypeScript)

```bash
cd frontend

# Initialize React app
npx create-react-app . --template typescript

# Configure with Claude Flow
claude flow setup react --path .
```

**Generated `frontend/package.json` scripts:**
```json
{
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --watchAll=false",
    "test:watch": "react-scripts test",
    "lint": "eslint src --ext .ts,.tsx",
    "format": "prettier --write \"src/**/*.{ts,tsx,json,css}\"",
    "typecheck": "tsc --noEmit",
    "validate": "npm run typecheck && npm run lint && npm test"
  }
}
```

### 4. Configure Backend (Python/FastAPI)

```bash
cd ../backend

# Create Python virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Configure with Claude Flow
claude flow setup python --path .
```

**Generated `backend/pyproject.toml`:**
```toml
[project]
name = "backend"
version = "0.1.0"
dependencies = [
    "fastapi>=0.100.0",
    "uvicorn[standard]>=0.23.0",
    "pydantic>=2.0.0",
    "sqlalchemy>=2.0.0",
    "alembic>=1.11.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
    "mypy>=1.0.0",
    "httpx>=0.24.0",
]

[tool.black]
line-length = 88
target-version = ['py311']

[tool.mypy]
python_version = "3.11"
strict = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
```

### 5. Create Shared Types/Contracts

```bash
cd ../shared

# Create shared TypeScript definitions
mkdir -p types
```

**`shared/types/api.ts`:**
```typescript
// Shared API contracts between frontend and backend

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'user';
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserRequest {
  email: string;
  name: string;
  password: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
}

export interface ApiError {
  message: string;
  code: string;
  details?: Record<string, any>;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

// API endpoints as constants
export const API_ENDPOINTS = {
  auth: {
    login: '/api/auth/login',
    logout: '/api/auth/logout',
    refresh: '/api/auth/refresh',
    register: '/api/auth/register',
  },
  users: {
    list: '/api/users',
    detail: (id: string) => `/api/users/${id}`,
    update: (id: string) => `/api/users/${id}`,
    delete: (id: string) => `/api/users/${id}`,
  },
} as const;
```

**Generate Python models from TypeScript:**
```bash
# Use Claude to generate Python equivalents
claude generate python-models --from shared/types/api.ts --to backend/app/models/api.py
```

**Generated `backend/app/models/api.py`:**
```python
"""API models matching TypeScript definitions."""
from datetime import datetime
from enum import Enum
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, EmailStr, Field


class UserRole(str, Enum):
    """User role enumeration."""
    ADMIN = "admin"
    USER = "user"


class User(BaseModel):
    """User model."""
    id: str
    email: EmailStr
    name: str
    role: UserRole
    created_at: datetime = Field(alias="createdAt")
    updated_at: datetime = Field(alias="updatedAt")
    
    class Config:
        populate_by_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class CreateUserRequest(BaseModel):
    """Create user request model."""
    email: EmailStr
    name: str
    password: str = Field(min_length=8)


class LoginRequest(BaseModel):
    """Login request model."""
    email: EmailStr
    password: str


class LoginResponse(BaseModel):
    """Login response model."""
    access_token: str = Field(alias="accessToken")
    refresh_token: str = Field(alias="refreshToken")
    user: User
    
    class Config:
        populate_by_name = True


class ApiError(BaseModel):
    """API error response model."""
    message: str
    code: str
    details: Optional[Dict[str, Any]] = None


class PaginatedResponse(BaseModel):
    """Paginated response model."""
    items: List[Any]
    total: int
    page: int
    page_size: int = Field(alias="pageSize")
    has_next: bool = Field(alias="hasNext")
    has_previous: bool = Field(alias="hasPrevious")
    
    class Config:
        populate_by_name = True


# API endpoints
class ApiEndpoints:
    """API endpoint definitions."""
    
    class Auth:
        login = "/api/auth/login"
        logout = "/api/auth/logout"
        refresh = "/api/auth/refresh"
        register = "/api/auth/register"
    
    class Users:
        list = "/api/users"
        
        @staticmethod
        def detail(user_id: str) -> str:
            return f"/api/users/{user_id}"
        
        @staticmethod
        def update(user_id: str) -> str:
            return f"/api/users/{user_id}"
        
        @staticmethod
        def delete(user_id: str) -> str:
            return f"/api/users/{user_id}"


API_ENDPOINTS = ApiEndpoints()
```

### 6. Implement Backend API

**`backend/app/main.py`:**
```python
"""Main FastAPI application."""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from typing import List

from .models.api import (
    User, CreateUserRequest, LoginRequest, LoginResponse,
    ApiError, PaginatedResponse
)
from .services.auth import AuthService
from .services.user import UserService
from .database import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    await init_db()
    yield
    # Shutdown
    await close_db()


app = FastAPI(
    title="Fullstack App API",
    version="0.1.0",
    lifespan=lifespan
)

# CORS configuration for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Services
auth_service = AuthService()
user_service = UserService()


@app.post("/api/auth/register", response_model=User)
async def register(request: CreateUserRequest) -> User:
    """Register a new user."""
    try:
        user = await user_service.create_user(request)
        return user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/auth/login", response_model=LoginResponse)
async def login(request: LoginRequest) -> LoginResponse:
    """Login user."""
    try:
        response = await auth_service.login(
            request.email,
            request.password
        )
        return response
    except ValueError as e:
        raise HTTPException(status_code=401, detail="Invalid credentials")


@app.get("/api/users", response_model=PaginatedResponse)
async def list_users(
    page: int = 1,
    page_size: int = 20
) -> PaginatedResponse:
    """List all users with pagination."""
    users, total = await user_service.list_users(page, page_size)
    
    return PaginatedResponse(
        items=users,
        total=total,
        page=page,
        page_size=page_size,
        has_next=page * page_size < total,
        has_previous=page > 1
    )
```

### 7. Implement Frontend API Client

**`frontend/src/services/api.ts`:**
```typescript
import axios, { AxiosInstance } from 'axios';
import { 
  User, 
  LoginRequest, 
  LoginResponse, 
  CreateUserRequest,
  PaginatedResponse,
  API_ENDPOINTS 
} from '../../../shared/types/api';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor for auth
    this.client.interceptors.request.use(
      config => {
        const token = localStorage.getItem('accessToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      error => Promise.reject(error)
    );

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      response => response,
      async error => {
        if (error.response?.status === 401) {
          // Handle token refresh or logout
          await this.handleUnauthorized();
        }
        return Promise.reject(error);
      }
    );
  }

  private async handleUnauthorized(): Promise<void> {
    // Implement token refresh logic
    const refreshToken = localStorage.getItem('refreshToken');
    if (refreshToken) {
      try {
        const response = await this.auth.refresh(refreshToken);
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
      } catch {
        // Refresh failed, logout
        this.auth.logout();
      }
    }
  }

  auth = {
    login: async (data: LoginRequest): Promise<LoginResponse> => {
      const response = await this.client.post<LoginResponse>(
        API_ENDPOINTS.auth.login,
        data
      );
      
      // Store tokens
      localStorage.setItem('accessToken', response.data.accessToken);
      localStorage.setItem('refreshToken', response.data.refreshToken);
      
      return response.data;
    },

    register: async (data: CreateUserRequest): Promise<User> => {
      const response = await this.client.post<User>(
        API_ENDPOINTS.auth.register,
        data
      );
      return response.data;
    },

    logout: async (): Promise<void> => {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      // Optionally call backend logout endpoint
      await this.client.post(API_ENDPOINTS.auth.logout);
    },

    refresh: async (refreshToken: string): Promise<LoginResponse> => {
      const response = await this.client.post<LoginResponse>(
        API_ENDPOINTS.auth.refresh,
        { refreshToken }
      );
      return response.data;
    },
  };

  users = {
    list: async (
      page: number = 1,
      pageSize: number = 20
    ): Promise<PaginatedResponse<User>> => {
      const response = await this.client.get<PaginatedResponse<User>>(
        API_ENDPOINTS.users.list,
        { params: { page, page_size: pageSize } }
      );
      return response.data;
    },

    get: async (id: string): Promise<User> => {
      const response = await this.client.get<User>(
        API_ENDPOINTS.users.detail(id)
      );
      return response.data;
    },

    update: async (id: string, data: Partial<User>): Promise<User> => {
      const response = await this.client.patch<User>(
        API_ENDPOINTS.users.update(id),
        data
      );
      return response.data;
    },

    delete: async (id: string): Promise<void> => {
      await this.client.delete(API_ENDPOINTS.users.delete(id));
    },
  };
}

export const apiClient = new ApiClient();
```

### 8. Unified Testing

**Root `Makefile`:**
```makefile
.PHONY: help install test lint format clean docker-up docker-down

help:
	@echo "Multi-language project commands:"
	@echo "  make install      - Install all dependencies"
	@echo "  make test        - Run all tests"
	@echo "  make lint        - Run all linters"
	@echo "  make format      - Format all code"
	@echo "  make validate    - Run all validations"
	@echo "  make docker-up   - Start all services"
	@echo "  make docker-down - Stop all services"
	@echo "  make clean       - Clean all build artifacts"

install: install-frontend install-backend

install-frontend:
	cd frontend && npm install

install-backend:
	cd backend && pip install -e ".[dev]"

test: test-frontend test-backend test-integration

test-frontend:
	cd frontend && npm test

test-backend:
	cd backend && pytest

test-integration:
	@echo "Running integration tests..."
	cd scripts && ./run-integration-tests.sh

lint: lint-frontend lint-backend

lint-frontend:
	cd frontend && npm run lint

lint-backend:
	cd backend && flake8 app tests && mypy app

format: format-frontend format-backend

format-frontend:
	cd frontend && npm run format

format-backend:
	cd backend && black app tests && isort app tests

validate: lint test
	@echo "✅ All validations passed!"

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

clean:
	rm -rf frontend/build frontend/node_modules
	rm -rf backend/__pycache__ backend/.pytest_cache
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
```

### 9. Docker Configuration

**`docker-compose.yml`:**
```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: ../docker/frontend.Dockerfile
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    volumes:
      - ./frontend/src:/app/src
      - ./shared:/app/shared:ro
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: ../docker/backend.Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./backend/app:/app/app
      - ./shared:/app/shared:ro
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=app
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  nginx:
    build:
      context: ./docker
      dockerfile: nginx.Dockerfile
    ports:
      - "80:80"
    depends_on:
      - frontend
      - backend

volumes:
  postgres_data:
```

**`docker/frontend.Dockerfile`:**
```dockerfile
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source and shared types
COPY . .
COPY ../shared /shared

# Build
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY ../docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**`docker/backend.Dockerfile`:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY pyproject.toml ./
RUN pip install -e .

# Copy application
COPY . .
COPY ../shared /shared

# Run migrations and start server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

### 10. CI/CD Configuration

**`.github/workflows/ci.yml`:**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Type check
        run: npm run typecheck
      
      - name: Test
        run: npm test -- --coverage
      
      - name: Build
        run: npm run build

  backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          pip install -e ".[dev]"
      
      - name: Lint
        run: |
          flake8 app tests
          mypy app
      
      - name: Test
        run: pytest --cov=app --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  integration:
    needs: [frontend, backend]
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Docker Compose
        run: |
          docker-compose build
          docker-compose up -d
      
      - name: Wait for services
        run: |
          scripts/wait-for-services.sh
      
      - name: Run integration tests
        run: |
          scripts/run-integration-tests.sh
      
      - name: Cleanup
        if: always()
        run: docker-compose down -v
```

## Working with Claude

### Cross-Language Features

```bash
# Generate matching models across languages
claude sync models --from shared/types --to-python backend/app/models --to-go services/api/models

# Add feature across stack
claude add feature "user notifications" --frontend --backend

# Refactor across languages
claude refactor "rename User.email to User.emailAddress" --all
```

### Language-Specific Commands

```bash
# Frontend specific
cd frontend
claude add component "NotificationBell with real-time updates"

# Backend specific
cd backend
claude add endpoint "GET /api/notifications with pagination"

# From root - target specific service
claude --service frontend add hook "useNotifications"
claude --service backend add migration "add_notifications_table"
```

## Best Practices

### 1. Shared Contracts
- Define API contracts in TypeScript (most expressive)
- Generate models for other languages
- Use OpenAPI/Swagger for documentation
- Version your API properly

### 2. Consistent Tooling
- Use similar linting rules across languages
- Standardize on formatting (Prettier, Black, gofmt)
- Common commit message format
- Unified CI/CD pipeline

### 3. Development Workflow
```bash
# Start all services
make docker-up

# Watch logs
docker-compose logs -f

# Run specific service
docker-compose up frontend

# Access services
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

### 4. Testing Strategy
- Unit tests per service
- Integration tests for API contracts
- E2E tests for critical user flows
- Contract tests between services

### 5. Dependency Management
- Pin major versions in all languages
- Regular dependency updates
- Security scanning in CI
- License compatibility checks

## Common Patterns

### API Gateway Pattern
```nginx
# nginx.conf for API gateway
location / {
    proxy_pass http://frontend:3000;
}

location /api {
    proxy_pass http://backend:8000;
}

location /auth {
    proxy_pass http://auth-service:8001;
}
```

### Shared Utilities
```bash
# Create shared utilities
shared/
├── types/          # TypeScript definitions
├── protos/         # Protocol buffers
├── openapi/        # OpenAPI specs
└── scripts/        # Build scripts
```

### Environment Configuration
```bash
# .env.development
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:8000
DATABASE_URL=postgresql://localhost:5432/dev

# .env.production
FRONTEND_URL=https://app.example.com
BACKEND_URL=https://api.example.com
DATABASE_URL=postgresql://prod-db:5432/app
```

## Troubleshooting

### Port Conflicts
```bash
# Check what's using a port
lsof -i :3000

# Change ports in docker-compose.override.yml
```

### Cross-Origin Issues
```python
# backend/app/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Type Mismatches
```bash
# Regenerate types when API changes
claude sync models --force

# Validate types match
claude validate types
```

## Next Steps

- Set up [CI/CD pipelines](./ci-cd-setup.md)
- Learn about [migration strategies](./migration-guide.md)
- Explore [JavaScript project setup](./javascript-project.md)