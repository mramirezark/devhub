import { getStoredAccessToken } from '../features/auth/authSlice'

export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000'

type ApiRequestOptions = RequestInit & {
  json?: unknown
}

export async function apiRequest<T>(
  path: string,
  options: ApiRequestOptions = {},
): Promise<T> {
  const { json, headers, ...rest } = options
  
  // Automatically include access token if available
  const token = getStoredAccessToken()
  const defaultHeaders: HeadersInit = {
    'Content-Type': 'application/json',
  }
  if (token) {
    defaultHeaders['Authorization'] = `Bearer ${token}`
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    credentials: 'include',
    headers: {
      ...defaultHeaders,
      ...(headers ?? {}),
    },
    body: json ? JSON.stringify(json) : rest.body,
    ...rest,
  })

  const contentType = response.headers.get('content-type') ?? ''
  const isJson = contentType.includes('application/json')

  if (!response.ok) {
    let message = response.statusText || 'Request failed'
    if (isJson) {
      try {
        const payload = await response.json()
        message =
          payload?.errors?.join(', ') ||
          payload?.error ||
          payload?.message ||
          message
      } catch {
        // noop – fallback to default message
      }
    }
    throw new Error(message)
  }

  if (response.status === 204) {
    return null as T
  }

  if (isJson) {
    return (await response.json()) as T
  }

  return (await response.text()) as T
}

