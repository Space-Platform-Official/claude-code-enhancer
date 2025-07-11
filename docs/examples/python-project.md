# Python Project Setup with Claude Flow

This guide demonstrates setting up a professional Python project with Claude Flow, including virtual environments, testing with pytest, and code quality tools.

## Prerequisites

- Python 3.8+ installed
- Git initialized in your project
- Claude Flow installed globally

## Step-by-Step Setup

### 1. Initialize Your Project

```bash
# Create project directory
mkdir my-python-app
cd my-python-app

# Initialize git
git init

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Initialize Claude Flow
claude flow init
```

**Expected Output:**
```
🚀 Initializing Claude Flow...
✅ Created .claude directory
✅ Created CLAUDE.md with project instructions
✅ Set up git hooks for automated checks
✅ Created Makefile with common commands

Claude Flow initialized successfully!
```

### 2. Configure Python Development Tools

```bash
# Set up Python tools (black, flake8, mypy, pytest)
claude flow setup python

# Or use interactive setup
claude flow setup
# Select: Python > Black + Flake8 + MyPy + Pytest
```

**Generated `pyproject.toml`:**
```toml
[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 88

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
addopts = "-v --cov=src --cov-report=html --cov-report=term"
```

**Generated `.flake8`:**
```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = 
    .git,
    __pycache__,
    venv,
    .venv,
    build,
    dist
per-file-ignores =
    __init__.py:F401
```

### 3. Install Dependencies

```bash
# Create requirements files
claude create requirements

# This generates:
# - requirements.txt (production dependencies)
# - requirements-dev.txt (development dependencies)
```

**Generated `requirements.txt`:**
```
# Production dependencies
pydantic>=2.0.0
python-dotenv>=1.0.0
```

**Generated `requirements-dev.txt`:**
```
# Development dependencies
-r requirements.txt

# Testing
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.0.0

# Code quality
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
isort>=5.0.0

# Documentation
sphinx>=6.0.0
sphinx-rtd-theme>=1.0.0
```

```bash
# Install all dependencies
pip install -r requirements-dev.txt
```

### 4. Create Project Structure

```bash
# Use Claude to create structure
claude create-structure --type python

# Creates:
mkdir -p src tests docs
touch src/__init__.py src/main.py src/models.py src/services.py
touch tests/__init__.py tests/test_models.py tests/test_services.py
touch README.md setup.py
```

**Example `src/models.py`:**
```python
"""Data models for the application."""
from datetime import datetime
from typing import Optional, List
from enum import Enum
from pydantic import BaseModel, Field, validator


class Priority(str, Enum):
    """Task priority levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class TaskStatus(str, Enum):
    """Task status options."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class Task(BaseModel):
    """Task model with validation."""
    
    id: Optional[str] = Field(default=None, description="Unique task identifier")
    title: str = Field(..., min_length=1, max_length=200, description="Task title")
    description: Optional[str] = Field(default="", description="Task description")
    priority: Priority = Field(default=Priority.MEDIUM, description="Task priority")
    status: TaskStatus = Field(default=TaskStatus.PENDING, description="Task status")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    
    @validator('title')
    def validate_title(cls, v: str) -> str:
        """Ensure title is not just whitespace."""
        if not v.strip():
            raise ValueError("Title cannot be empty or just whitespace")
        return v.strip()
    
    def complete(self) -> None:
        """Mark task as completed."""
        self.status = TaskStatus.COMPLETED
        self.completed_at = datetime.now()
        self.updated_at = datetime.now()
    
    def update_priority(self, priority: Priority) -> None:
        """Update task priority."""
        self.priority = priority
        self.updated_at = datetime.now()
    
    class Config:
        """Pydantic configuration."""
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }
```

**Example `src/services.py`:**
```python
"""Business logic services."""
from typing import List, Optional, Dict
from uuid import uuid4
from datetime import datetime

from .models import Task, TaskStatus, Priority


class TaskService:
    """Service for managing tasks."""
    
    def __init__(self) -> None:
        """Initialize task service."""
        self._tasks: Dict[str, Task] = {}
    
    def create_task(
        self,
        title: str,
        description: str = "",
        priority: Priority = Priority.MEDIUM
    ) -> Task:
        """Create a new task.
        
        Args:
            title: Task title
            description: Task description
            priority: Task priority level
            
        Returns:
            Created task instance
        """
        task = Task(
            id=str(uuid4()),
            title=title,
            description=description,
            priority=priority
        )
        self._tasks[task.id] = task
        return task
    
    def get_task(self, task_id: str) -> Optional[Task]:
        """Get task by ID.
        
        Args:
            task_id: Task identifier
            
        Returns:
            Task if found, None otherwise
        """
        return self._tasks.get(task_id)
    
    def list_tasks(
        self,
        status: Optional[TaskStatus] = None,
        priority: Optional[Priority] = None
    ) -> List[Task]:
        """List tasks with optional filtering.
        
        Args:
            status: Filter by status
            priority: Filter by priority
            
        Returns:
            List of tasks matching criteria
        """
        tasks = list(self._tasks.values())
        
        if status:
            tasks = [t for t in tasks if t.status == status]
        
        if priority:
            tasks = [t for t in tasks if t.priority == priority]
        
        return sorted(tasks, key=lambda t: t.created_at, reverse=True)
    
    def complete_task(self, task_id: str) -> Optional[Task]:
        """Mark task as completed.
        
        Args:
            task_id: Task identifier
            
        Returns:
            Updated task if found, None otherwise
        """
        task = self.get_task(task_id)
        if task:
            task.complete()
        return task
    
    def delete_task(self, task_id: str) -> bool:
        """Delete a task.
        
        Args:
            task_id: Task identifier
            
        Returns:
            True if deleted, False if not found
        """
        if task_id in self._tasks:
            del self._tasks[task_id]
            return True
        return False
```

**Example `tests/test_services.py`:**
```python
"""Tests for task service."""
import pytest
from datetime import datetime

from src.models import Task, TaskStatus, Priority
from src.services import TaskService


class TestTaskService:
    """Test cases for TaskService."""
    
    @pytest.fixture
    def service(self) -> TaskService:
        """Create task service instance."""
        return TaskService()
    
    def test_create_task(self, service: TaskService) -> None:
        """Test task creation."""
        task = service.create_task(
            title="Test Task",
            description="Test description",
            priority=Priority.HIGH
        )
        
        assert task.id is not None
        assert task.title == "Test Task"
        assert task.description == "Test description"
        assert task.priority == Priority.HIGH
        assert task.status == TaskStatus.PENDING
        assert isinstance(task.created_at, datetime)
    
    def test_create_task_minimal(self, service: TaskService) -> None:
        """Test task creation with minimal data."""
        task = service.create_task(title="Minimal Task")
        
        assert task.title == "Minimal Task"
        assert task.description == ""
        assert task.priority == Priority.MEDIUM
    
    def test_get_task(self, service: TaskService) -> None:
        """Test retrieving a task."""
        created_task = service.create_task(title="Find me")
        found_task = service.get_task(created_task.id)
        
        assert found_task is not None
        assert found_task.id == created_task.id
        assert found_task.title == "Find me"
    
    def test_get_nonexistent_task(self, service: TaskService) -> None:
        """Test retrieving non-existent task."""
        task = service.get_task("nonexistent-id")
        assert task is None
    
    def test_list_tasks(self, service: TaskService) -> None:
        """Test listing all tasks."""
        task1 = service.create_task(title="Task 1")
        task2 = service.create_task(title="Task 2")
        
        tasks = service.list_tasks()
        
        assert len(tasks) == 2
        # Tasks should be sorted by creation date (newest first)
        assert tasks[0].id == task2.id
        assert tasks[1].id == task1.id
    
    def test_list_tasks_by_status(self, service: TaskService) -> None:
        """Test filtering tasks by status."""
        task1 = service.create_task(title="Pending Task")
        task2 = service.create_task(title="Complete Task")
        service.complete_task(task2.id)
        
        pending_tasks = service.list_tasks(status=TaskStatus.PENDING)
        completed_tasks = service.list_tasks(status=TaskStatus.COMPLETED)
        
        assert len(pending_tasks) == 1
        assert pending_tasks[0].id == task1.id
        
        assert len(completed_tasks) == 1
        assert completed_tasks[0].id == task2.id
    
    def test_complete_task(self, service: TaskService) -> None:
        """Test completing a task."""
        task = service.create_task(title="To Complete")
        completed = service.complete_task(task.id)
        
        assert completed is not None
        assert completed.status == TaskStatus.COMPLETED
        assert completed.completed_at is not None
        assert completed.updated_at is not None
    
    def test_delete_task(self, service: TaskService) -> None:
        """Test deleting a task."""
        task = service.create_task(title="To Delete")
        
        # Verify task exists
        assert service.get_task(task.id) is not None
        
        # Delete task
        deleted = service.delete_task(task.id)
        assert deleted is True
        
        # Verify task is gone
        assert service.get_task(task.id) is None
        
        # Try deleting again
        deleted_again = service.delete_task(task.id)
        assert deleted_again is False
```

### 5. Configure Git Hooks

Claude Flow automatically configures git hooks. Let's verify:

```bash
# Stage changes
git add .

# Attempt commit (will trigger hooks)
git commit -m "Initial Python project setup"
```

**Pre-commit output:**
```
🔍 Running pre-commit checks...
✅ Black: All files formatted
✅ isort: Imports sorted
✅ Flake8: No style issues
✅ MyPy: Type checking passed
✅ Pytest: All tests passing (8/8)

Commit successful!
```

### 6. Create Makefile Commands

Claude Flow generates a Makefile with Python-specific commands:

```makefile
.PHONY: help install test lint format type-check clean

help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make test      - Run tests with coverage"
	@echo "  make lint      - Run linting checks"
	@echo "  make format    - Format code"
	@echo "  make type-check - Run type checking"
	@echo "  make clean     - Clean up temporary files"
	@echo "  make all       - Run all checks"

install:
	pip install -r requirements-dev.txt

test:
	pytest

lint:
	flake8 src tests
	isort --check-only src tests

format:
	black src tests
	isort src tests

type-check:
	mypy src

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .mypy_cache .coverage htmlcov

all: format lint type-check test
```

### 7. Working with Claude

Use Claude for Python development:

```bash
# Add a new feature
claude add feature "Add task tagging functionality"

# Claude will:
# 1. Analyze existing code structure
# 2. Create implementation plan
# 3. Add Tag model and update Task
# 4. Implement with full test coverage
# 5. Ensure type hints are correct
```

**Example Claude session:**
```
You: Add task tagging functionality

Claude: Let me research the codebase and create a plan before implementing.

*Analyzes models.py and services.py*

Plan:
1. Create Tag model in models.py
2. Add tags field to Task model
3. Add tag management methods to TaskService
4. Write comprehensive tests
5. Ensure type hints and documentation

*Implements with proper Python patterns*

✅ Implementation complete! All checks passing:
- Black: Formatted
- Flake8: Clean
- MyPy: No type errors
- Tests: 15/15 passing with 98% coverage
```

### 8. Create setup.py

```python
"""Setup configuration for the package."""
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="my-python-app",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="A task management application",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/my-python-app",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        "pydantic>=2.0.0",
        "python-dotenv>=1.0.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
            "black>=23.0.0",
            "flake8>=6.0.0",
            "mypy>=1.0.0",
            "isort>=5.0.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "my-app=main:main",
        ],
    },
)
```

### 9. CI/CD with GitHub Actions

Create `.github/workflows/python-ci.yml`:

```yaml
name: Python CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Cache pip
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements*.txt') }}
        restore-keys: |
          ${{ runner.os }}-pip-
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements-dev.txt
    
    - name: Format check
      run: |
        black --check src tests
        isort --check-only src tests
    
    - name: Lint
      run: flake8 src tests
    
    - name: Type check
      run: mypy src
    
    - name: Test with pytest
      run: pytest --cov=src --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        fail_ci_if_error: true
```

## Project Structure

Final project structure:

```
my-python-app/
├── .claude/
│   ├── commands/
│   └── hooks/
├── .github/
│   └── workflows/
│       └── python-ci.yml
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── models.py
│   └── services.py
├── tests/
│   ├── __init__.py
│   ├── test_models.py
│   └── test_services.py
├── docs/
├── .flake8
├── .gitignore
├── CLAUDE.md
├── Makefile
├── pyproject.toml
├── README.md
├── requirements.txt
├── requirements-dev.txt
└── setup.py
```

## Common Commands

```bash
# Development
python -m src.main        # Run application
pytest                    # Run all tests
pytest -v                 # Verbose test output
pytest --cov             # Run with coverage

# Code quality
make lint                # Check code style
make format              # Auto-format code
make type-check          # Check type hints
make all                 # Run all checks

# Claude Flow
claude validate          # Run all validations
claude add feature       # Add new feature
claude fix mypy         # Fix type errors

# Package management
pip install -e .         # Install package in dev mode
python setup.py sdist    # Create source distribution
```

## Best Practices

1. **Always use type hints** - MyPy will catch many bugs
2. **Write tests first** - Use pytest fixtures for reusable test data
3. **Follow PEP 8** - Black and flake8 enforce this automatically
4. **Document with docstrings** - Use Google or NumPy style
5. **Use virtual environments** - Keep dependencies isolated

## Troubleshooting

### MyPy errors
```bash
# Show error codes
mypy src --show-error-codes

# Ignore specific error
# type: ignore[error-code]

# Use Claude to fix
claude fix mypy
```

### Import errors
```bash
# Ensure package is installed
pip install -e .

# Check Python path
python -c "import sys; print(sys.path)"
```

### Test coverage issues
```bash
# Generate HTML report
pytest --cov=src --cov-report=html

# Open htmlcov/index.html in browser
# Use Claude to add missing tests
claude add tests --coverage 90
```

## Next Steps

- Learn about [multi-language projects](./multi-language.md)
- Set up [CI/CD pipelines](./ci-cd-setup.md)
- Explore [migration strategies](./migration-guide.md)