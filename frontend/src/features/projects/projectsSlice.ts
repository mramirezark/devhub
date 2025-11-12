import { createSlice, type PayloadAction } from '@reduxjs/toolkit'
import type { ProjectFormMode } from './types'

interface ProjectsUiState {
  isFormOpen: boolean
  mode: ProjectFormMode
  editingProjectId: string | null
}

const initialState: ProjectsUiState = {
  isFormOpen: false,
  mode: 'create',
  editingProjectId: null,
}

const projectsSlice = createSlice({
  name: 'projectsUi',
  initialState,
  reducers: {
    openCreateForm(state) {
      state.isFormOpen = true
      state.mode = 'create'
      state.editingProjectId = null
    },
    openEditForm(state, action: PayloadAction<string>) {
      state.isFormOpen = true
      state.mode = 'edit'
      state.editingProjectId = action.payload
    },
    closeForm() {
      return initialState
    },
  },
})

export const { openCreateForm, openEditForm, closeForm } = projectsSlice.actions
export default projectsSlice.reducer

