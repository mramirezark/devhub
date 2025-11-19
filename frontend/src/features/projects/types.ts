export interface ProjectSummary {
  id: string
  name: string
  description?: string | null
  taskCount: number
}

export interface PageInfo {
  hasNextPage: boolean
  endCursor?: string | null
}

export interface Connection<T> {
  nodes: T[]
  pageInfo: PageInfo
}

export interface ProjectNode {
  id: string
  name: string
  description?: string | null
  tasks: Array<{ id: string }>
}

export interface ProjectsQueryResponse {
  projects: Connection<ProjectNode>
}

export interface ProjectInput {
  name: string
  description?: string
}

export type ProjectFormMode = 'create' | 'edit'

export interface CreateProjectResponse {
  createProject: {
    project: {
      id: string
      name: string
      description?: string | null
      tasks: Array<{ id: string }>
    } | null
    errors: string[]
  }
}

export interface UpdateProjectResponse {
  updateProject: {
    project: {
      id: string
      name: string
      description?: string | null
      tasks: Array<{ id: string }>
    } | null
    errors: string[]
  }
}

export interface DeleteProjectResponse {
  deleteProject: {
    success: boolean
    errors: string[]
  }
}

