import { createSlice, type PayloadAction } from '@reduxjs/toolkit'
import type { UserFormMode } from './types'

interface UsersUiState {
  isFormOpen: boolean
  mode: UserFormMode
  editingUserId: string | null
}

const initialState: UsersUiState = {
  isFormOpen: false,
  mode: 'create',
  editingUserId: null,
}

const usersSlice = createSlice({
  name: 'usersUi',
  initialState,
  reducers: {
    openUserCreateForm(state) {
      state.isFormOpen = true
      state.mode = 'create'
      state.editingUserId = null
    },
    openUserEditForm(state, action: PayloadAction<string>) {
      state.isFormOpen = true
      state.mode = 'edit'
      state.editingUserId = action.payload
    },
    closeUserForm() {
      return initialState
    },
  },
})

export const { openUserCreateForm, openUserEditForm, closeUserForm } =
  usersSlice.actions
export default usersSlice.reducer

