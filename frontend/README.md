# Frontend (React + TypeScript + Redux + Apollo)

A modern single-page application built with React, TypeScript, Redux Toolkit, and Apollo Client for managing tasks, projects, and users. The frontend communicates with a Rails backend via both REST and GraphQL APIs.

## Features

- **JWT Token Authentication**: Stateless authentication with access and refresh tokens
- **GraphQL Integration**: Apollo Client for efficient data fetching and caching
- **REST API Integration**: RESTful endpoints for authentication and user management
- **Redux Toolkit**: Modern state management for UI state and authentication
- **TypeScript**: Full type safety across the application
- **Dark/Light Theme**: System-aware theme switching with persistent preferences
- **Responsive Design**: Material-inspired dashboard that works across devices
- **Real-time Updates**: Automatic refetching and cache invalidation

## Getting Started

### Prerequisites

- Node.js 18+ (check with `node --version`)
- npm or yarn
- Backend API running (see backend README)

### Installation

1. **Install dependencies**

   ```bash
   cd frontend
   npm install
   ```

2. **Configure environment variables**

   Create a `.env` file in the `frontend` directory:

   ```bash
   # Base URL for REST API endpoints
   VITE_API_BASE_URL=http://localhost:3000

   # GraphQL endpoint
   VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
   ```

   > **Note**: Adjust the URLs if the backend runs elsewhere (e.g., inside Docker or on a remote host).

3. **Start the development server**

   ```bash
   npm run dev
   ```

   The application will be available at `http://localhost:5173` by default.

4. **Build for production**

   ```bash
   npm run build
   ```

   This will type-check the code and create an optimized production bundle in the `dist/` directory.

5. **Preview production build**

   ```bash
   npm run preview
   ```

   Serves the production build locally for testing.

## Architecture

### State Management

The application uses **Redux Toolkit** for state management:

- **Auth Slice** (`src/features/auth/authSlice.ts`): Manages authentication state, JWT tokens (stored in localStorage), and user session
- **Tasks Slice** (`src/features/tasks/tasksSlice.ts`): Manages task filters, activity visibility, and UI state
- **Projects Slice** (`src/features/projects/projectsSlice.ts`): Manages project-related UI state
- **Users Slice** (`src/features/users/usersSlice.ts`): Manages user-related UI state

### Data Fetching

- **Apollo Client** (`src/lib/apolloClient.ts`): Handles all GraphQL queries and mutations with automatic caching, error handling, and token-based authentication
- **HTTP Client** (`src/lib/http.ts`): Utility for REST API requests with automatic token injection

### Authentication

The application implements **JWT token-based authentication**:

1. **Login Flow**: User logs in via `POST /session` → receives `access_token` and `refresh_token`
2. **Token Storage**: Tokens are stored in `localStorage` (`devhub_access_token`, `devhub_refresh_token`)
3. **Token Usage**: Access token is automatically included in `Authorization: Bearer <token>` header for all API requests
4. **Token Refresh**: When access token expires, the app can call `POST /session/refresh` to obtain new tokens (implementation pending)

#### Token Management

- **Access Token**: Short-lived (15 minutes), used for API requests
- **Refresh Token**: Long-lived (30 days), used to obtain new access tokens
- **Storage**: Tokens are stored in `localStorage` (client-side only)
- **Security**: Tokens are included in request headers, not cookies (stateless)

### Project Structure

```
frontend/
├── src/
│   ├── app/                    # Redux store configuration
│   │   ├── hooks.ts           # Typed Redux hooks
│   │   └── store.ts           # Store configuration
│   ├── components/            # Shared components
│   │   ├── Modal.tsx         # Reusable modal component
│   │   └── index.ts          # Component exports
│   ├── features/             # Feature-based organization
│   │   ├── auth/             # Authentication
│   │   │   ├── authSlice.ts  # Auth Redux slice
│   │   │   ├── types.ts      # Auth TypeScript types
│   │   │   └── components/   # Auth UI components
│   │   ├── tasks/            # Task management
│   │   │   ├── tasksSlice.ts # Tasks Redux slice
│   │   │   ├── graphql.ts    # GraphQL queries/mutations
│   │   │   ├── types.ts      # Task TypeScript types
│   │   │   └── components/   # Task UI components
│   │   ├── projects/         # Project management
│   │   ├── users/            # User management (admin)
│   │   └── theme/            # Theme toggle component
│   ├── lib/                   # Utility libraries
│   │   ├── apolloClient.ts   # Apollo Client setup
│   │   └── http.ts           # REST API client
│   ├── theme/                 # Theme system
│   │   ├── ThemeProvider.tsx # Theme context provider
│   │   └── index.ts          # Theme exports
│   ├── App.tsx               # Main application component
│   ├── App.css               # Global styles
│   ├── index.css             # Base styles
│   └── main.tsx              # Application entry point
├── public/                   # Static assets
├── dist/                     # Production build output
├── .env                      # Environment variables
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── vite.config.ts            # Vite configuration
└── README.md                 # This file
```

### Feature Modules

#### Tasks (`src/features/tasks/`)

- **TaskDashboard**: Main dashboard component with filters, summary metrics, and task list
- **TaskList**: Displays tasks in a table with status, assignee, due date, and actions
- **TaskForm**: Modal form for creating/editing tasks
- **TaskFilters**: Filter controls for status, project, and assignee
- **TaskActivityTimeline**: Shows activity history for a task

#### Projects (`src/features/projects/`)

- **ProjectsPanel**: Main panel for managing projects
- **ProjectList**: Displays projects with task counts
- **ProjectForm**: Modal form for creating/editing projects
- **ProjectToolbar**: Toolbar with create button and filters

#### Users (`src/features/users/`) - Admin Only

- **UsersPanel**: Main panel for user management (admin only)
- **UserList**: Displays users with roles and actions
- **UserForm**: Modal form for creating/editing users
- **UserToolbar**: Toolbar with create button

#### Authentication (`src/features/auth/`)

- **AuthPanel**: Login/signup form component
- **authSlice**: Redux slice managing auth state and token storage
- Token management functions: `getStoredAccessToken()`, `getStoredRefreshToken()`

## Styling

The application uses **plain CSS** with CSS variables for theming:

- **Theme System**: Dark/light mode support via CSS variables
- **Material Design**: Material-inspired component styling
- **Responsive**: Mobile-friendly breakpoints
- **CSS Variables**: Defined in `:root` and `[data-theme="dark"]` selectors

### Theme Variables

CSS variables are defined for:
- Colors (primary, secondary, surface, text, etc.)
- Spacing and sizing
- Border radius and shadows
- Transitions and animations

## GraphQL Integration

### Apollo Client Setup

- **Endpoint**: Configured via `VITE_GRAPHQL_ENDPOINT`
- **Authentication**: Automatically includes `Authorization: Bearer <token>` header
- **Caching**: InMemoryCache for efficient data management
- **Error Handling**: Global error link for logging GraphQL errors

### GraphQL Queries

GraphQL queries are defined in feature-specific files:
- `src/features/tasks/graphql.ts` - Task-related queries and mutations
- `src/features/projects/graphql.ts` - Project-related queries and mutations
- `src/features/users/graphql.ts` - User-related queries and mutations

Example query:
```typescript
import { gql } from '@apollo/client'

export const GET_TASKS = gql`
  query GetTasks($status: TaskStatus, $projectId: ID) {
    tasks(status: $status, projectId: $projectId) {
      id
      title
      description
      status
      dueAt
      assignee {
        id
        name
      }
      project {
        id
        name
      }
    }
  }
`
```

## REST API Integration

### HTTP Client

The `src/lib/http.ts` module provides a utility for making REST API requests:

- **Automatic Token Injection**: Includes access token in `Authorization` header
- **Error Handling**: Parses and throws meaningful errors
- **JSON Support**: Handles JSON request/response bodies
- **Credentials**: Includes cookies for session-based auth fallback

Example usage:
```typescript
import { apiRequest } from '../lib/http'

// GET request
const user = await apiRequest<User>('/profile')

// POST request
const result = await apiRequest<AuthResponse>('/users', {
  method: 'POST',
  json: {
    user: {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'SecurePass123',
      password_confirmation: 'SecurePass123'
    }
  }
})
```

### Authentication Endpoints

- **POST /users** - Register a new user
- **POST /session** - Login (returns JWT tokens)
- **POST /session/refresh** - Refresh JWT tokens
- **DELETE /session** - Logout
- **GET /profile** - Get current user profile

## Environment Variables

### Required Variables

- `VITE_API_BASE_URL` (default: `http://localhost:3000`): Base URL for REST API endpoints
- `VITE_GRAPHQL_ENDPOINT` (default: `http://localhost:3000/graphql`): GraphQL endpoint URL

### Example `.env` File

```bash
VITE_API_BASE_URL=http://localhost:3000
VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
```

> **Note**: Vite requires the `VITE_` prefix for environment variables to be exposed to the client.

## Development

### Available Scripts

- **`npm run dev`**: Start development server with hot module replacement
- **`npm run build`**: Build for production (includes TypeScript type checking)
- **`npm run preview`**: Preview the production build locally
- **`npm run lint`**: Run ESLint to check code quality

### Development Workflow

1. Start the backend API (see backend README)
2. Create/update `.env` file with backend URLs
3. Run `npm run dev`
4. Open `http://localhost:5173`
5. Log in with admin credentials (default: `admin@example.com` / `Admin123`)

### Type Checking

TypeScript type checking is included in the build process. To check types without building:

```bash
npx tsc --noEmit
```

### Code Quality

The project uses **ESLint** for code quality:

```bash
npm run lint
```

## Building for Production

1. **Update environment variables** for production:
   ```bash
   VITE_API_BASE_URL=https://api.example.com
   VITE_GRAPHQL_ENDPOINT=https://api.example.com/graphql
   ```

2. **Build the application**:
   ```bash
   npm run build
   ```

3. **Preview the build** (optional):
   ```bash
   npm run preview
   ```

4. **Deploy** the `dist/` directory to your hosting provider (e.g., Vercel, Netlify, AWS S3 + CloudFront)

### Production Considerations

- Ensure CORS is properly configured on the backend for your frontend domain
- Set secure environment variables (never commit `.env` files)
- Use HTTPS in production
- Consider implementing token refresh logic for better UX
- Monitor and handle 401 errors (expired tokens) gracefully

## Authentication Flow

1. **Initial Load**: App checks `localStorage` for stored access token
2. **Token Verification**: If token exists, calls `GET /profile` to verify
3. **Login**: User enters credentials → `POST /session` → tokens stored in `localStorage`
4. **API Requests**: All requests automatically include `Authorization: Bearer <token>` header
5. **Token Expiration**: When access token expires, client should call `POST /session/refresh`
6. **Logout**: Clears tokens from `localStorage` and calls `DELETE /session`

## Troubleshooting

### CORS Errors

If you see CORS errors, ensure:
- Backend `ALLOWED_CORS_ORIGINS` includes your frontend URL
- Frontend includes `credentials: 'include'` in requests (already handled in code)

### Authentication Issues

- Check that tokens are being stored in `localStorage`
- Verify backend JWT secret is configured
- Check browser console for token-related errors
- Ensure `Authorization` header is being sent (check Network tab)

### GraphQL Errors

- Verify `VITE_GRAPHQL_ENDPOINT` is correct
- Check Apollo Client DevTools (if installed) for query/mutation details
- Verify backend GraphQL endpoint is accessible

## Dependencies

### Core

- **React 19.2.0**: UI library
- **TypeScript 5.9.3**: Type safety
- **Vite 7.2.2**: Build tool and dev server

### State Management

- **Redux Toolkit 2.10.1**: State management
- **React Redux 9.2.0**: React bindings for Redux

### Data Fetching

- **Apollo Client 4.0.9**: GraphQL client
- **GraphQL 16.12.0**: GraphQL query language

## License

[Add your license here]
