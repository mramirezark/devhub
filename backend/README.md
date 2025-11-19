# Backend API

This Rails API provides project and task management with polymorphic task assignments, asynchronous tracking of updates, and both REST and GraphQL interfaces for querying and mutating data.

## Features

- **Dual Authentication**: JWT tokens (stateless) + Authlogic sessions (stateful) for flexible authentication
- **GraphQL API**: Full-featured GraphQL endpoint with queries and mutations
- **REST API**: RESTful endpoints for user registration, session management, and profiles
- **Background Jobs**: Sidekiq-powered async job processing for activity tracking
- **Engine Architecture**: Modular design with Admin and Core engines
- **Comprehensive Testing**: Minitest and RSpec test suites

## Getting Started

### Prerequisites

- Ruby 3.1+ (check `.ruby-version`)
- PostgreSQL 9.3+
- Bundler

### Installation

1. **Install dependencies**

   ```bash
   bundle install
   ```

2. **Configure environment variables**

   Create a `.env` file in the backend directory (or set environment variables):

   ```bash
   # Database
   DATABASE_URL=postgresql://localhost/devhub_development
   
   # JWT Secret (required for token-based authentication)
   # Option 1: Set via environment variable
   JWT_SECRET_KEY=your-secret-key-here
   
   # Option 2: Use Rails credentials (recommended for production)
   # Run: bin/rails credentials:edit
   # Add under jwt: secret_key: your-secret-key-here
   
   # CORS Origins (comma-separated)
   ALLOWED_CORS_ORIGINS=http://localhost:5173,http://localhost:3000
   
   # Admin Account (for seeding)
   ADMIN_EMAIL=admin@example.com
   ADMIN_PASSWORD=Admin123
   ADMIN_NAME="DevHub Admin"
   ```

   > **Note**: If `JWT_SECRET_KEY` is not set, the application will fall back to `Rails.application.secret_key_base` (not recommended for production).

3. **Configure the database**

   Update `config/database.yml` as needed, then create and migrate:

   ```bash
   bin/rails db:prepare
   ```

4. **Seed the database (optional)**

   Create a default admin account:

   ```bash
   bin/rails db:seed
   ```

   Or with custom credentials:

   ```bash
   ADMIN_EMAIL=admin@example.com \
   ADMIN_PASSWORD=SecurePass123 \
   ADMIN_NAME="DevHub Admin" \
   bin/rails db:seed
   ```

5. **Run background job processor**

   Sidekiq powers Active Job in this app. Launch the worker alongside the API:

   ```bash
   bundle exec sidekiq
   ```

   Or in development, you can use the Rails console to process jobs synchronously.

6. **Start the API server**

   ```bash
   bin/rails server
   ```

   The API will be available at `http://localhost:3000`.

## API Endpoints

### REST Endpoints

#### Authentication

- **POST /users** – Register a new user
  ```json
  {
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "SecurePass123",
      "password_confirmation": "SecurePass123"
    }
  }
  ```
  
  **Password Requirements**: Must contain at least one uppercase letter, one lowercase letter, and one number.

- **POST /session** – Log in (returns JWT tokens)
  ```json
  {
    "session": {
      "email": "john@example.com",
      "password": "SecurePass123",
      "remember_me": true
    }
  }
  ```
  
  **Response**:
  ```json
  {
    "user": {
      "id": "1",
      "name": "John Doe",
      "email": "john@example.com",
      "admin": false
    },
    "access_token": "eyJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```

- **POST /session/refresh** – Refresh JWT tokens
  ```json
  {
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```
  
  **Response**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```

- **DELETE /session** – Log out (destroys session cookie)

- **GET /profile** – Get current user profile (requires authentication)

#### Admin Endpoints (via Admin Engine)

- **GET /admin/users** – List all users (admin only)
- **POST /admin/users** – Create user (admin only)
- **PATCH /admin/users/:id** – Update user (admin only)
- **DELETE /admin/users/:id** – Delete user (admin only)

### GraphQL Endpoint

- **POST /graphql** – GraphQL query/mutation endpoint

  Example query:
  ```graphql
  query ProjectsWithTasks {
    projects {
      id
      name
      tasks(status: IN_PROGRESS) {
        id
        title
        status
        assignee {
          id
          name
        }
        activities {
          action
          createdAt
        }
      }
    }
  }
  ```

  Example mutation:
  ```graphql
  mutation CreateProject($name: String!) {
    createProject(input: { name: $name }) {
      project {
        id
        name
      }
      errors
    }
  }
  ```

## Authentication

The application supports **dual authentication methods**:

### 1. JWT Token Authentication (Primary)

- **Access Tokens**: Short-lived (15 minutes), used for API requests
- **Refresh Tokens**: Long-lived (30 days), used to obtain new access tokens
- **Usage**: Send tokens in the `Authorization` header: `Authorization: Bearer <access_token>`
- **Stateless**: No server-side session storage required

### 2. Authlogic Session Authentication (Fallback)

- **Cookie-based**: Uses `_devhub_session` cookie
- **Stateful**: Requires server-side session storage
- **Usage**: Automatically handled via cookies when `credentials: 'include'` is used

### Authentication Flow

1. User logs in via `POST /session` → receives `access_token` and `refresh_token`
2. Client stores tokens (typically in localStorage)
3. Client includes `Authorization: Bearer <access_token>` in API requests
4. When access token expires, client calls `POST /session/refresh` with refresh token
5. Server returns new access and refresh tokens

### CORS Configuration

When consuming the API from a cross-origin frontend:

- Ensure `ALLOWED_CORS_ORIGINS` includes your frontend origin
- Include `credentials: 'include'` in fetch/Apollo requests
- For cookie-based auth, the session cookie will be automatically included
- For JWT auth, manually include the `Authorization` header

## Domain Overview

### Models

- **User** – User accounts with authentication. Fields: `name`, `email`, `password_digest`, `admin` (boolean)
- **Project** – Groups related tasks. Fields: `name`, `description`
- **Task** – Belongs to a project. Fields: `title`, `description`, `status` (enum: `PENDING`, `IN_PROGRESS`, `COMPLETED`), `due_at`, `assignee_type` (polymorphic), `assignee_id`
- **Activity** – Audit trail entries. Fields: `action` (string), `record_type` (polymorphic), `record_id`, `created_at`
- **UserSession** – Authlogic session model for cookie-based authentication

### Polymorphic Associations

- **Task Assignees**: Tasks can be assigned to any model via `assignee_type`/`assignee_id` (currently supports `User`)
- **Activity Records**: Activities track changes to any model via `record_type`/`record_id`

## Background Jobs

- **ActivityLoggerJob** – Records audit trail entries asynchronously when tasks are created or updated
- **TaskStatusUpdater** – Handles task status changes and triggers activity logging

Jobs are processed by Sidekiq. Monitor job queues via Sidekiq Web UI (available at `/sidekiq` in development/test).

## Testing

The project uses both **Minitest** and **RSpec** for testing:

### Running Tests

```bash
# Run all Minitest tests
bin/rails test

# Run all RSpec tests
bundle exec rspec

# Run specific test file
bin/rails test test/models/user_test.rb

# Run with coverage
COVERAGE=true bin/rails test
```

### Test Factories

FactoryBot factories are available in `test/factories/` for creating test data:

- `users` – Create user records
- `projects` – Create project records
- `tasks` – Create task records
- `activities` – Create activity records

Example:
```ruby
user = FactoryBot.create(:user, email: "test@example.com", admin: true)
project = FactoryBot.create(:project, name: "Test Project")
task = FactoryBot.create(:task, project: project, assignee: user)
```

### Test Data

Passwords in tests must meet complexity requirements:
- At least one uppercase letter
- At least one lowercase letter
- At least one number

Example: `"Password123"` or `"SecurePass123"`

## Code Quality

### Static Analysis

The project includes several code quality tools:

```bash
# RuboCop (Ruby style checker)
bin/rubocop

# Brakeman (security scanner)
bin/brakeman

# Bundler Audit (gem vulnerability scanner)
bin/bundler-audit

# Comprehensive audit (all tools)
bin/ci
```

## Engine Architecture

The application is organized into modular engines:

### Admin Engine

- **Location**: `app/engines/admin/`
- **Mount Point**: `/admin`
- **Purpose**: Administrative functionality (user management, etc.)
- **Services**: `Admin::Services::UserService`

### Core Engine

- **Location**: `app/engines/core/`
- **Purpose**: Core business logic (task management, etc.)
- **Services**: `Core::Services::TaskService`, `Core::Services::ProjectService`

Engines are loaded automatically via `config/initializers/engine_services.rb`.

## Deployment

The project includes Kamal deployment configuration:

1. **Configure deployment**: Edit `config/deploy.yml`
2. **Set secrets**: Configure `.kamal/secrets` (never commit raw credentials)
3. **Deploy**: `bin/kamal deploy`

### Production Environment Variables

Required environment variables for production:

- `DATABASE_URL` – PostgreSQL connection string
- `RAILS_MASTER_KEY` – Rails master key (from `config/master.key`)
- `JWT_SECRET_KEY` – JWT secret key (or use Rails credentials)
- `ALLOWED_CORS_ORIGINS` – Comma-separated list of allowed origins
- `DEVHUB_DATABASE_PASSWORD` – Database password (if not using DATABASE_URL)
- `CACHE_DATABASE_URL` – Cache database connection (optional)
- `QUEUE_DATABASE_URL` – Queue database connection (optional)
- `CABLE_DATABASE_URL` – Action Cable database connection (optional)

### Database Setup

The production database configuration supports multiple databases:

- **Primary**: Main application database
- **Cache**: Solid Cache database (optional, uses primary if not specified)
- **Queue**: Solid Queue database (optional, uses primary if not specified)
- **Cable**: Solid Cable database (optional, uses primary if not specified)

## Development

### Running in Development

```bash
# Start Rails server
bin/rails server

# Start Sidekiq worker (in another terminal)
bundle exec sidekiq

# Or use the dev script
bin/dev
```

### Useful Commands

```bash
# Rails console
bin/rails console

# Database migrations
bin/rails db:migrate

# Rollback migration
bin/rails db:rollback

# Generate migration
bin/rails generate migration AddFieldToModel

# Generate model
bin/rails generate model ModelName field:type

# Generate GraphQL type
bin/rails generate graphql:object ModelName

# Generate GraphQL mutation
bin/rails generate graphql:mutation CreateModel
```

## License

[Add your license here]
