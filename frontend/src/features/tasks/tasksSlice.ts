import { createSlice } from '@reduxjs/toolkit'
import type { PayloadAction } from '@reduxjs/toolkit'
import type { TaskStatus } from './types'

export type StatusFilter = TaskStatus | 'ALL'

interface TasksUiState {
  projectId: string | null
  status: StatusFilter
  search: string
  showActivities: boolean
  isFormOpen: boolean
  formMode: 'create' | 'edit'
  editingTaskId: string | null
}

const initialState: TasksUiState = {
  projectId: null,
  status: 'ALL',
  search: '',
  showActivities: true,
  isFormOpen: false,
  formMode: 'create',
  editingTaskId: null,
}

const tasksSlice = createSlice({
  name: 'tasks',
  initialState,
  reducers: {
    setProjectFilter(state, action: PayloadAction<string | null>) {
      state.projectId = action.payload
    },
    setStatusFilter(state, action: PayloadAction<StatusFilter>) {
      state.status = action.payload
    },
    setSearch(state, action: PayloadAction<string>) {
      state.search = action.payload
    },
    toggleShowActivities(state) {
      state.showActivities = !state.showActivities
    },
    resetFilters() {
      return initialState
    },
    openTaskCreateForm(state) {
      state.isFormOpen = true
      state.formMode = 'create'
      state.editingTaskId = null
    },
    openTaskEditForm(state, action: PayloadAction<string>) {
      state.isFormOpen = true
      state.formMode = 'edit'
      state.editingTaskId = action.payload
    },
    closeTaskForm(state) {
      state.isFormOpen = false
      state.formMode = 'create'
      state.editingTaskId = null
    },
  },
})

export const {
  setProjectFilter,
  setStatusFilter,
  setSearch,
  toggleShowActivities,
  resetFilters,
  openTaskCreateForm,
  openTaskEditForm,
  closeTaskForm,
} = tasksSlice.actions

export default tasksSlice.reducer

