import { configureStore } from '@reduxjs/toolkit'
import tasksReducer from '../features/tasks/tasksSlice'
import authReducer from '../features/auth/authSlice'
import projectsUiReducer from '../features/projects/projectsSlice'
import usersUiReducer from '../features/users/usersSlice'

export const store = configureStore({
  reducer: {
    tasks: tasksReducer,
    auth: authReducer,
    projectsUi: projectsUiReducer,
    usersUi: usersUiReducer,
  },
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

