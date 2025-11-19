# DevHub

A full-stack project and task management application with a Rails GraphQL/REST API backend and a modern React frontend. Features JWT token-based authentication, real-time activity tracking, and a responsive Material Design-inspired interface.

## Features

- **📋 Project Management**: Create, update, and organize projects with descriptions and task tracking
- **✅ Task Tracking**: Manage tasks with status (Pending, In Progress, Completed), assignees, due dates, and descriptions
- **👥 User Management**: User accounts with role-based access (Administrator, Member)
- **🔐 Dual Authentication**: JWT token-based (stateless) + Authlogic session-based (stateful) authentication
- **📊 Activity Logging**: Automatic audit trail for all task changes with timestamps
- **🔍 GraphQL API**: Flexible and efficient data fetching with GraphQL queries and mutations
- **🌐 REST API**: Traditional REST endpoints for authentication and user management
- **🎨 Modern UI**: Material Design-inspired dashboard with dark/light theme support
- **📱 Responsive Design**: Works seamlessly across desktop, tablet, and mobile devices
- **⚡ Real-time Updates**: Automatic refetching and cache invalidation for fresh data

## Project Structure

```
devhub/
├── backend/              # Rails API with GraphQL and REST
│   ├── app/
│   │   ├── controllers/  # REST API controllers
│   │   ├── graphql/      # GraphQL schema, queries, mutations
│   │   ├── models/       # ActiveRecord models
│   │   ├── services/     # Business logic (JWT, auth, tasks)
│   │   ├── jobs/         # Background jobs (Sidekiq)
│   │   └── engines/      # Modular engines (Admin, Core)
│   ├── config/           # Rails configuration
│   ├── db/               # Database migrations and schema
│   ├── test/             # Minitest tests
│   └── spec/             # RSpec tests
│
└── frontend/             # React SPA with TypeScript
    ├── src/
    │   ├── app/          # Redux store configuration
    │   ├── features/     # Feature-based modules
    │   │   ├── auth/     # Authentication (JWT token management)
    │   │   ├── tasks/    # Task management
    │   │   ├── projects/ # Project management
    │   │   ├── users/    # User management (admin)
    │   │   └── theme/    # Theme toggle
    │   ├── lib/          # Utilities (Apollo Client, HTTP client)
    │   └── theme/        # Theme provider
    └── dist/             # Production build output
```

## Technology Stack

### Backend
- **Ruby 3.4.5** with Rails 7.1
- **PostgreSQL** for data persistence
- **GraphQL** for flexible API queries
- **JWT** for stateless token authentication
- **Authlogic** for session-based authentication
- **Sidekiq** for background job processing
- **Minitest** & **RSpec** for testing

### Frontend
- **React 19.2** with TypeScript
- **Redux Toolkit** for state management
- **Apollo Client** for GraphQL data fetching
- **Vite** for fast development and building
- **CSS Variables** for theming

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.4.5** (check `.ruby-version` in backend directory)
- **Node.js 18+** (check with `node --version`)
- **PostgreSQL 9.3+**
- **Bundler** (`gem install bundler`)
- **npm** or **yarn**

## Quick Start

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install Ruby dependencies
bundle install

# Set up environment variables (optional, uses defaults if not set)
# Create .env file or export:
# export DATABASE_URL=postgresql://localhost/devhub_development
# export JWT_SECRET_KEY=your-secret-key-here
# export ALLOWED_CORS_ORIGINS=http://localhost:5173

# Set up and seed the database
bin/rails db:prepare
bin/rails db:seed

# Start the Rails server
bin/rails server
```

The backend API will be available at:
- REST API: `http://localhost:3000`
- GraphQL: `http://localhost:3000/graphql`
- Sidekiq Dashboard: `http://localhost:3000/sidekiq` (development/test only)

**Default Admin Account** (created by seeding):
- Email: `admin@example.com`
- Password: `admin123`

> **Note**: Make sure PostgreSQL is running. If using different database credentials, update `config/database.yml` or set `DATABASE_URL` environment variable.

### 2. Frontend Setup

```bash
# Navigate to frontend directory (in a new terminal)
cd frontend

# Install Node.js dependencies
npm install

# Create .env file
cat <<'EOF' > .env
VITE_API_BASE_URL=http://localhost:3000
VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
EOF

# Start the development server
npm run dev
```

The frontend will be available at `http://localhost:5173`.

### 3. Running Background Jobs

For background jobs (activity logging), start Sidekiq in a separate terminal:

```bash
cd backend
bundle exec sidekiq
```

Or use the bundled dev script to run both server and jobs:

```bash
cd backend
bin/dev
```

## Authentication

The application supports **dual authentication methods**:

### JWT Token Authentication (Primary)
- **Access Tokens**: Short-lived (15 minutes) for API requests
- **Refresh Tokens**: Long-lived (30 days) for obtaining new access tokens
- **Storage**: Tokens stored in browser `localStorage`
- **Usage**: Automatically included in `Authorization: Bearer <token>` header

### Authlogic Session Authentication (Fallback)
- **Cookie-based**: Uses `_devhub_session` cookie
- **Stateful**: Requires server-side session storage
- **Usage**: Automatically handled when `credentials: 'include'` is used

### Authentication Flow

1. User logs in → Frontend calls `POST /session`
2. Backend validates credentials → Returns `access_token` and `refresh_token`
3. Frontend stores tokens in `localStorage`
4. All subsequent API requests include `Authorization: Bearer <access_token>`
5. When access token expires → Frontend calls `POST /session/refresh`
6. Backend returns new access and refresh tokens

## API Documentation

### REST Endpoints

- **POST /users** - Register a new user
- **POST /session** - Login (returns JWT tokens)
- **POST /session/refresh** - Refresh JWT tokens
- **DELETE /session** - Logout
- **GET /profile** - Get current user profile
- **GET /admin/users** - List users (admin only)
- **POST /admin/users** - Create user (admin only)
- **PATCH /admin/users/:id** - Update user (admin only)
- **DELETE /admin/users/:id** - Delete user (admin only)

### GraphQL Endpoint

- **POST /graphql** - GraphQL queries and mutations

See [backend/README.md](./backend/README.md) for detailed API documentation and examples.

## Development

### Running Tests

**Backend** (Minitest):
```bash
cd backend
bin/rails test
```

**Backend** (RSpec):
```bash
cd backend
bundle exec rspec
```

**Frontend**:
```bash
cd frontend
npm run lint
# Type checking is included in build
npm run build
```

### Code Quality

**Backend**:
```bash
cd backend
bin/rubocop      # Ruby style checker
bin/brakeman     # Security scanner
bin/bundler-audit # Dependency vulnerability scanner
bin/ci           # Run all checks
```

**Frontend**:
```bash
cd frontend
npm run lint     # ESLint
```

### Database Management

```bash
cd backend

# Create migration
bin/rails generate migration MigrationName

# Run migrations
bin/rails db:migrate

# Rollback migration
bin/rails db:rollback

# Reset database (⚠️ destroys all data)
bin/rails db:reset

# Seed database
bin/rails db:seed
```

## Environment Variables

### Backend

Create a `.env` file in the `backend/` directory or export environment variables:

```bash
# Database
DATABASE_URL=postgresql://localhost/devhub_development

# JWT Secret (required for token authentication)
JWT_SECRET_KEY=your-secret-key-here

# CORS Origins (comma-separated)
ALLOWED_CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Admin account for seeding
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=Admin123
ADMIN_NAME="DevHub Admin"
```

> **Note**: Alternatively, store `JWT_SECRET_KEY` in Rails credentials: `bin/rails credentials:edit` → add under `jwt: secret_key:`

### Frontend

Create a `.env` file in the `frontend/` directory:

```bash
# Base URL for REST API
VITE_API_BASE_URL=http://localhost:3000

# GraphQL endpoint
VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
```

## Building for Production

### Backend

The backend can be deployed using Kamal (see `config/deploy.yml`) or any Rails-compatible hosting:

```bash
cd backend

# Ensure production environment variables are set
# Build and deploy using Kamal
bin/kamal deploy
```

### Frontend

```bash
cd frontend

# Update .env with production URLs
VITE_API_BASE_URL=https://api.example.com
VITE_GRAPHQL_ENDPOINT=https://api.example.com/graphql

# Build for production
npm run build

# Preview production build
npm run preview
```

Deploy the `dist/` directory to your static hosting provider (Vercel, Netlify, AWS S3 + CloudFront, etc.).

## Project Structure Details

### Backend Architecture

- **Controllers**: Handle REST API requests (users, sessions, profiles, admin)
- **GraphQL**: Schema, queries, mutations, and types defined in `app/graphql/`
- **Models**: User, Project, Task, Activity with polymorphic associations
- **Services**: Business logic (JWT, authentication, task management)
- **Engines**: Modular engines for Admin and Core functionality
- **Jobs**: Background jobs for async operations (activity logging)

### Frontend Architecture

- **Features**: Feature-based modules (auth, tasks, projects, users)
- **State Management**: Redux Toolkit slices for each feature
- **Data Fetching**: Apollo Client for GraphQL, custom HTTP client for REST
- **Components**: React components organized by feature
- **Theme**: CSS variables-based theming with dark/light mode

## Troubleshooting

### Backend Issues

**Database connection errors**:
- Ensure PostgreSQL is running
- Check `DATABASE_URL` or `config/database.yml`
- Verify database exists: `bin/rails db:create`

**Authentication errors**:
- Verify `JWT_SECRET_KEY` is set
- Check CORS configuration in `config/initializers/cors.rb`
- Ensure `ALLOWED_CORS_ORIGINS` includes frontend URL

**Background jobs not processing**:
- Start Sidekiq: `bundle exec sidekiq`
- Check Sidekiq dashboard: `http://localhost:3000/sidekiq`

### Frontend Issues

**CORS errors**:
- Ensure backend `ALLOWED_CORS_ORIGINS` includes frontend URL
- Verify `VITE_API_BASE_URL` matches backend URL

**Authentication not working**:
- Check browser console for errors
- Verify tokens are stored in `localStorage`
- Check Network tab for `Authorization` header
- Ensure backend JWT secret is configured

**GraphQL errors**:
- Verify `VITE_GRAPHQL_ENDPOINT` is correct
- Check backend GraphQL endpoint is accessible
- Review Apollo Client DevTools (if installed)

## Documentation

For more detailed documentation, see:

- [Backend README](./backend/README.md) - Backend API documentation, authentication details, GraphQL schema
- [Frontend README](./frontend/README.md) - Frontend architecture, state management, component structure

## License

[Add your license here]

## Support

For issues, questions, or contributions, please open an issue on the repository.
