import { gql } from '@apollo/client'

export const USERS_QUERY = gql`
  query UsersList {
    users {
      id
      name
      email
      admin
    }
  }
`

export const CREATE_USER_MUTATION = gql`
  mutation CreateUser(
    $name: String!
    $email: String!
    $password: String!
    $passwordConfirmation: String
    $admin: Boolean
  ) {
    createUser(
      input: {
        name: $name
        email: $email
        password: $password
        passwordConfirmation: $passwordConfirmation
        admin: $admin
      }
    ) {
      user {
        id
        name
        email
        admin
      }
      errors
    }
  }
`

export const UPDATE_USER_MUTATION = gql`
  mutation UpdateUser($id: ID!, $name: String, $email: String, $admin: Boolean) {
    updateUser(input: { id: $id, name: $name, email: $email, admin: $admin }) {
      user {
        id
        name
        email
        admin
      }
      errors
    }
  }
`

export const DELETE_USER_MUTATION = gql`
  mutation DeleteUser($id: ID!) {
    deleteUser(input: { id: $id }) {
      success
      errors
    }
  }
`

