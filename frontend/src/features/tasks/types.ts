export type TaskStatus = 'PENDING' | 'IN_PROGRESS' | 'COMPLETED'

export interface Activity {
  id: string
  action: string
  createdAt: string
}

export interface Project {
  id: string
  name: string
}

export interface User {
  id: string
  name: string
  email: string
}

export interface Task {
  id: string
  title: string
  description?: string | null
  status: TaskStatus
  dueAt?: string | null
  project: Project
  assignee?: User | null
  activities: Activity[]
}

export interface TasksResponse {
  tasks: Task[]
  projects: Project[]
  assignableUsers: User[]
}

export interface TaskFormInput {
  projectId: string
  title: string
  description?: string
  status: TaskStatus
  assigneeId?: string | null
  dueAt?: string | null
}

export type TaskFormMode = 'create' | 'edit'

export interface CreateTaskResponse {
  createTask: {
    task: Task | null
    errors: string[]
  }
}

export interface UpdateTaskResponse {
  updateTask: {
    task: Task | null
    errors: string[]
  }
}

export interface DeleteTaskResponse {
  deleteTask: {
    success: boolean
    errors: string[]
  }
}

export interface AssignTaskResponse {
  assignTaskToUser: {
    task: {
      id: string
      assignee?: User | null
    } | null
    errors: string[]
  }
}

