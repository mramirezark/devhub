# DevHub

A full-stack project and task management application with a Rails GraphQL API backend and a React frontend.

## Project Structure

```
devhub/
├── backend/          # Rails API with GraphQL
└── frontend/         # React + Redux + Apollo Client
```

## Quick Start

### Prerequisites

- Ruby 3.4.0+
- Node.js 18+
- PostgreSQL

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```

4. Start the Rails server:
   ```bash
   bin/rails server
   ```

The GraphQL endpoint will be available at `http://localhost:3000/graphql`.

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file:
   ```bash
   cat <<'EOF' > .env
   VITE_API_BASE_URL=http://localhost:3000
   VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
   EOF
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

The frontend will be available at `http://localhost:5173`.

## Features

- **Project Management**: Create and manage projects
- **Task Tracking**: Assign tasks to users with status tracking
- **User Authentication**: Session-based authentication with Authlogic
- **Activity Logging**: Automatic audit trail for task changes
- **GraphQL API**: Flexible querying and mutations
- **Modern UI**: Material-inspired dashboard with dark mode support

## Technology Stack

### Backend
- Ruby on Rails 7.1
- GraphQL
- PostgreSQL
- Authlogic (authentication)
- Sidekiq (background jobs)

### Frontend
- React 18
- Redux Toolkit
- Apollo Client
- TypeScript
- Vite

## Development

See the individual README files in `backend/README.md` and `frontend/README.md` for more detailed information about each part of the application.

## License

[Add your license here]

