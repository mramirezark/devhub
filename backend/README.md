# Backend API

This Rails API provides project and task management with polymorphic task assignments, asynchronous tracking of updates, and a GraphQL interface for querying and mutating data.

## Getting Started

1. **Install dependencies**

   ```bash
   bundle install
   ```

2. **Configure the database**

   Update `config/database.yml` as needed, then create/migrate:

   ```bash
   bin/rails db:prepare
   ```

3. **Run background job processor**

   Solid Queue powers Active Job in this app. Launch the worker alongside the API:

   ```bash
   bin/rails solid_queue:start
   ```

4. **Start the API server**

   ```bash
   bin/rails server
   ```

   The GraphQL endpoint is available at `POST /graphql`.

## Domain Overview

- `Project` – groups related tasks.
- `Task` – belongs to a project, tracks status (`PENDING`, `IN_PROGRESS`, `COMPLETED`), optional due date, and enqueues activity logging on create/update.
- `User` – authenticates via Authlogic session cookies and can be assigned to tasks via the polymorphic `assignee_type`/`assignee_id` pairing stored on each task.
- `Activity` – stores asynchronous audit entries (polymorphic `record_type/record_id`) with a descriptive `action` string for each change.

## GraphQL Usage

Example query fetching projects, tasks, assignees, and recent updates:

```graphql
query ProjectsWithTasks {
  projects {
    id
    name
    tasks(status: IN_PROGRESS) {
      id
      title
      status
      assignees {
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

Example mutation to create a project, create a task, and assign it to a user:

```graphql
mutation ManageTasks($projectName: String!, $taskTitle: String!, $userId: ID!) {
  createProject(input: { name: $projectName }) {
    project {
      id
    }
    errors
  }
  createTask(
    input: {
      projectId: "<PROJECT_ID>"
      title: $taskTitle
      status: PENDING
    }
  ) {
    task {
      id
    }
    errors
  }
  assignTaskToUser(
    input: {
      taskId: "<TASK_ID>"
      userId: "<USER_ID>"
    }
  ) {
    task {
      id
      assignee {
        name
      }
      activities {
        action
      }
    }
    errors
  }
}
```

> Replace `<PROJECT_ID>`, `<TASK_ID>`, and `<USER_ID>` with either numeric IDs (e.g. `"1"`) or Relay-style global IDs (`gid://backend/...`) obtained from prior GraphQL responses. The server resolves either format automatically.

## Testing & Linting

This project was generated with `--api -T`, so no test framework is bundled by default. Consider adding RSpec or Minitest along with factories to cover core models, GraphQL queries, and mutations. Static analysis tooling (Rubocop, Brakeman, bundler-audit) is vendored via `bin/` scripts.

## Background Job Insights

`ActivityLoggerJob` records a structured audit trail for task changes and assignments. Each entry references the affected record polymorphically and stores a descriptive `action` for what changed. Review `Activity` records via the `activities` GraphQL field to monitor activity.

## User Authentication

User accounts require a password at creation time. REST endpoints expose session management via Authlogic:

- `POST /users` – register a user. Body: `{ "user": { "name": "...", "email": "...", "password": "...", "password_confirmation": "..." } }`
- `POST /session` – log in. Body: `{ "session": { "email": "...", "password": "...", "remember_me": true } }`
- `DELETE /session` – log out (destroys the existing session cookie).
- `GET /profile` – returns the currently logged-in user (requires a valid session cookie).

Rails issues an `authlogic` session cookie (`_devhub_session`). When consuming the API from a browser or cross-origin frontend, ensure credentials/cookies are included in fetch/Apollo requests (`credentials: 'include'`) and that `ALLOWED_CORS_ORIGINS` reflects the frontend’s origin.

### Default Admin Account

`bin/rails db:seed` creates or updates a default administrator account. Override credentials via environment variables before seeding:

```bash
ADMIN_EMAIL=admin@example.com \
ADMIN_PASSWORD=admin123 \
ADMIN_NAME="DevHub Admin" \
bin/rails db:seed
```

If variables are not provided, the defaults shown above are used (remember to change them in production).
