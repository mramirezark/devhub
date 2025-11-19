export interface UserSummary {
  id: string
  name: string
  email: string
  admin?: boolean
}

export interface AuthState {
  currentUser: UserSummary | null
  loading: boolean
  error: string | null
  status: 'idle' | 'authenticating' | 'authenticated'
}

export interface SignUpPayload {
  name: string
  email: string
  password: string
  passwordConfirmation: string
}

export interface LoginPayload {
  email: string
  password: string
  rememberMe?: boolean
}

export interface AuthResponse {
  user: UserSummary
  access_token?: string
  refresh_token?: string
}

