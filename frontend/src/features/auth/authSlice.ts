import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import type {
  AuthState,
  AuthResponse,
  LoginPayload,
  SignUpPayload,
  UserSummary,
} from './types'
import { API_BASE_URL, apiRequest } from '../../lib/http'

const initialState: AuthState = {
  currentUser: null,
  loading: false,
  error: null,
  status: 'idle',
}

export const initializeAuth = createAsyncThunk<
  UserSummary | null,
  void,
  { rejectValue: string }
>('auth/initialize', async (_, { rejectWithValue }) => {
  try {
    const response = await fetch(`${API_BASE_URL}/profile`, {
      credentials: 'include',
    })

    if (response.status === 401) {
      return null
    }

    if (!response.ok) {
      const text = await response.text()
      throw new Error(text || 'Failed to verify session')
    }

    const payload: AuthResponse = await response.json()
    return payload.user
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Unable to verify session'
    return rejectWithValue(message)
  }
})

export const signup = createAsyncThunk<
  UserSummary,
  SignUpPayload,
  { rejectValue: string }
>('auth/signup', async (payload, { rejectWithValue }) => {
  try {
    const response = await apiRequest<AuthResponse>('/users', {
      method: 'POST',
      json: {
        user: {
          name: payload.name,
          email: payload.email,
          password: payload.password,
          password_confirmation: payload.passwordConfirmation,
        },
      },
    })
    return response.user
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Unable to sign up right now'
    return rejectWithValue(message)
  }
})

export const login = createAsyncThunk<
  UserSummary,
  LoginPayload,
  { rejectValue: string }
>('auth/login', async (payload, { rejectWithValue }) => {
  try {
    const response = await apiRequest<AuthResponse>('/session', {
      method: 'POST',
      json: {
        session: {
          email: payload.email,
          password: payload.password,
          remember_me: payload.rememberMe ?? false,
        },
      },
    })
    return response.user
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Unable to log in right now'
    return rejectWithValue(message)
  }
})

export const logout = createAsyncThunk<void, void, { rejectValue: string }>(
  'auth/logout',
  async (_, { rejectWithValue }) => {
    try {
      await apiRequest('/session', { method: 'DELETE' })
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unable to log out right now'
      return rejectWithValue(message)
    }
  },
)

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    clearAuthError(state) {
      state.error = null
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(initializeAuth.pending, (state) => {
        state.loading = true
        state.error = null
      })
      .addCase(initializeAuth.fulfilled, (state, action) => {
        state.loading = false
        if (action.payload) {
          state.currentUser = action.payload
          state.status = 'authenticated'
        } else {
          state.currentUser = null
          state.status = 'idle'
        }
      })
      .addCase(initializeAuth.rejected, (state, action) => {
        state.loading = false
        state.status = 'idle'
        if (action.payload) {
          state.error = action.payload
        }
      })
      .addCase(signup.pending, (state) => {
        state.status = 'authenticating'
        state.loading = true
        state.error = null
      })
      .addCase(signup.fulfilled, (state, action) => {
        state.loading = false
        state.status = 'authenticated'
        state.currentUser = action.payload
      })
      .addCase(signup.rejected, (state, action) => {
        state.loading = false
        state.status = 'idle'
        state.error = action.payload ?? 'Unable to sign up'
      })
      .addCase(login.pending, (state) => {
        state.status = 'authenticating'
        state.loading = true
        state.error = null
      })
      .addCase(login.fulfilled, (state, action) => {
        state.loading = false
        state.status = 'authenticated'
        state.currentUser = action.payload
      })
      .addCase(login.rejected, (state, action) => {
        state.loading = false
        state.status = 'idle'
        state.error = action.payload ?? 'Unable to log in'
      })
      .addCase(logout.pending, (state) => {
        state.loading = true
        state.error = null
      })
      .addCase(logout.fulfilled, (state) => {
        state.loading = false
        state.status = 'idle'
        state.currentUser = null
      })
      .addCase(logout.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload ?? 'Unable to log out'
      })
  },
})

export const { clearAuthError } = authSlice.actions
export default authSlice.reducer

