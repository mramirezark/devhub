# Frontend (React + Redux + Apollo)

This Vite-powered single-page app provides task dashboards that consume the Rails GraphQL API.

## Getting Started

1. Install dependencies (already run once after scaffolding):

   ```bash
   cd frontend
   npm install
   ```

2. Create a `.env` file (same directory) so the client knows where to find the Rails API:

   ```bash
   cat <<'EOF' > .env
   VITE_API_BASE_URL=http://localhost:3000
   VITE_GRAPHQL_ENDPOINT=http://localhost:3000/graphql
   EOF
   ```

   Adjust the URLs if the backend runs elsewhere (e.g., inside Docker or on a remote host). Both REST and GraphQL requests include credentials by default so sessions work cross-origin.

3. Start the dev server:

   ```bash
   npm run dev
   ```

   The dashboard lives at http://localhost:5173 by default. It will automatically reconnect to the Rails API when filters change or refetches occur.

4. Type-check or build for production:

   ```bash
   npm run build    # type-checks and creates an optimized bundle
   npm run preview  # serve the build output locally
   ```

## Architecture

- **Redux Toolkit** tracks lightweight UI state (filters, toggles) under `src/features/tasks/tasksSlice.ts`.
- **Auth slice** (`src/features/auth/authSlice.ts`) coordinates sign-up/login/logout flows and stores the current session state.
- **Apollo Client** (`src/lib/apolloClient.ts`) handles GraphQL caching, queries, and error logging.
- **Task dashboard** components live in `src/features/tasks/components/`:
  - `TaskDashboard` orchestrates filters, queries, and summary metrics.
  - `TaskList`, `TaskActivityTimeline`, `TaskForm`, and `TaskFilters` render the UI and CRUD controls.
- Queries are defined in `src/features/tasks/graphql.ts` and leverage the Rails `tasks`, `projects`, and `activities` GraphQL fields.
- **Projects workflow** lives in `src/features/projects/`:
  - `ProjectsPanel` fetches data, orchestrates inline forms, and connects Redux UI state with Apollo mutations.
  - Smaller components (`ProjectToolbar`, `ProjectList`, `ProjectCard`, `ProjectForm`) keep the UI modular and focused.
- **User management** lives in `src/features/users/`:
  - `UsersPanel` lists accounts, and uses `UserForm` / `UserList` / `UserToolbar` for scoped CRUD interactions.
  - Supports setting administrator privileges and removing users via GraphQL mutations.
- **Theme system** lives under `src/theme/` and `src/features/theme/`:
  - `ThemeProvider` hydrates from `localStorage`, reacts to OS preferences, and toggles the `data-theme` attribute for CSS variables.
  - `ThemeToggle` renders in the header so users can switch between light and dark palettes instantly.
- **Material-inspired layout** (see `App.tsx` / `App.css`) renders a vertical navigation rail with iconography, a top application bar with search/actions, and responsive content cards styled via CSS variables.
- The left sidebar lets you pick Tasks, Projects, or Users, while the top bar hosts global search, notifications, theming, and session controls.

Styling is plain CSS tailored for a Material Dashboard-like experience that stays responsive across breakpoints.

## Environment Variables

- `VITE_GRAPHQL_ENDPOINT` (required): URL of the Rails GraphQL endpoint. Defaults to `http://localhost:3000/graphql` if not set, but you should still supply it explicitly in `.env` for clarity.
- `VITE_API_BASE_URL` (required): Base URL for REST endpoints (`/users`, `/session`, `/profile`). Defaults to `http://localhost:3000`.

Optional advanced Apollo options (authentication headers, custom links, etc.) can be added to `src/lib/apolloClient.ts`.
