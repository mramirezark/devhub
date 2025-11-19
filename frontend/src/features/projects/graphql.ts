import { gql } from '@apollo/client'

export const PROJECTS_QUERY = gql`
  query ProjectList($first: Int) {
    projects(first: $first) {
      nodes {
        id
        name
        description
        tasks {
          id
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`

export const CREATE_PROJECT_MUTATION = gql`
  mutation CreateProject($name: String!, $description: String) {
    createProject(input: { name: $name, description: $description }) {
      project {
        id
        name
        description
        tasks {
          id
        }
      }
      errors
    }
  }
`

export const UPDATE_PROJECT_MUTATION = gql`
  mutation UpdateProject($id: ID!, $name: String, $description: String) {
    updateProject(input: { id: $id, name: $name, description: $description }) {
      project {
        id
        name
        description
        tasks {
          id
        }
      }
      errors
    }
  }
`

export const DELETE_PROJECT_MUTATION = gql`
  mutation DeleteProject($id: ID!) {
    deleteProject(input: { id: $id }) {
      success
      errors
    }
  }
`

