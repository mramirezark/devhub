export interface UserSummary {
  id: string
  name: string
  email: string
  admin: boolean
}

export interface PageInfo {
  hasNextPage: boolean
  endCursor?: string | null
}

export interface Connection<T> {
  nodes: T[]
  pageInfo: PageInfo
}

export interface UsersQueryResponse {
  users: Connection<UserSummary>
}

export interface UserFormInput {
  name: string
  email: string
  password?: string
  passwordConfirmation?: string
  admin: boolean
}

export type UserFormMode = 'create' | 'edit'

export interface CreateUserResponse {
  createUser: {
    user: UserSummary | null
    errors: string[]
  }
}

export interface UpdateUserResponse {
  updateUser: {
    user: UserSummary | null
    errors: string[]
  }
}

export interface DeleteUserResponse {
  deleteUser: {
    success: boolean
    errors: string[]
  }
}

