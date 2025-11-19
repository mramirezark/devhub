import { gql } from '@apollo/client'

export const TASK_DASHBOARD_QUERY = gql`
  query TaskDashboard($status: TaskStatusEnum, $projectId: ID, $first: Int) {
    tasks(status: $status, projectId: $projectId, first: $first) {
      nodes {
        id
        title
        description
        status
        dueAt
        assignee {
          id
          name
          email
        }
        project {
          id
          name
        }
        activities {
          id
          action
          createdAt
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
    projects(first: $first) {
      nodes {
        id
        name
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
    assignableUsers(first: $first) {
      nodes {
        id
        name
        email
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`

export const CREATE_TASK_MUTATION = gql`
  mutation CreateTask(
    $projectId: ID!
    $title: String!
    $description: String
    $status: TaskStatusEnum
    $dueAt: ISO8601DateTime
  ) {
    createTask(
      input: {
        projectId: $projectId
        title: $title
        description: $description
        status: $status
        dueAt: $dueAt
      }
    ) {
      task {
        id
        title
        description
        status
        dueAt
        project {
          id
          name
        }
        assignee {
          id
          name
          email
        }
        activities {
          id
          action
          createdAt
        }
      }
      errors
    }
  }
`

export const UPDATE_TASK_MUTATION = gql`
  mutation UpdateTask(
    $id: ID!
    $title: String
    $description: String
    $status: TaskStatusEnum
    $dueAt: ISO8601DateTime
  ) {
    updateTask(
      input: {
        id: $id
        title: $title
        description: $description
        status: $status
        dueAt: $dueAt
      }
    ) {
      task {
        id
        title
        description
        status
        dueAt
        project {
          id
          name
        }
        assignee {
          id
          name
          email
        }
        activities {
          id
          action
          createdAt
        }
      }
      errors
    }
  }
`

export const DELETE_TASK_MUTATION = gql`
  mutation DeleteTask($id: ID!) {
    deleteTask(input: { id: $id }) {
      success
      errors
    }
  }
`

export const ASSIGN_TASK_TO_USER_MUTATION = gql`
  mutation AssignTaskToUser($taskId: ID!, $userId: ID!) {
    assignTaskToUser(input: { taskId: $taskId, userId: $userId }) {
      task {
        id
        assignee {
          id
          name
          email
        }
      }
      errors
    }
  }
`

