import { type FormEvent, useEffect, useMemo, useState } from 'react'
import { useAppDispatch, useAppSelector } from '../../../app/hooks'
import {
  clearAuthError,
  login,
  signup,
} from '../authSlice'
import type { LoginPayload, SignUpPayload } from '../types'

type AuthMode = 'login' | 'signup'

const initialSignupState: SignUpPayload = {
  name: '',
  email: '',
  password: '',
  passwordConfirmation: '',
}

const initialLoginState: LoginPayload = {
  email: '',
  password: '',
  rememberMe: true,
}

const FIELD_MAX_LENGTH = 80

export function AuthPanel() {
  const dispatch = useAppDispatch()
  const auth = useAppSelector((state) => state.auth)

  const [mode, setMode] = useState<AuthMode>('login')
  const [signupForm, setSignupForm] = useState(initialSignupState)
  const [loginForm, setLoginForm] = useState(initialLoginState)
  const [formError, setFormError] = useState<string | null>(null)

  const isAuthenticating = useMemo(
    () => auth.loading || auth.status === 'authenticating',
    [auth.loading, auth.status],
  )

  useEffect(() => {
    if (auth.status === 'authenticated') {
      setSignupForm(initialSignupState)
      setLoginForm(initialLoginState)
      setFormError(null)
    }
  }, [auth.status])

  const switchMode = (nextMode: AuthMode) => {
    setMode(nextMode)
    setFormError(null)
    dispatch(clearAuthError())
  }

  const handleSignupSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setFormError(null)

    if (!signupForm.name.trim()) {
      setFormError('Please provide your name.')
      return
    }

    if (signupForm.password !== signupForm.passwordConfirmation) {
      setFormError('Passwords do not match.')
      return
    }

    dispatch(signup(signupForm))
  }

  const handleLoginSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setFormError(null)
    dispatch(login(loginForm))
  }

  return (
    <section className="auth-panel">
      <div className="auth-panel__tabs">
        <button
          type="button"
          className={`auth-panel__tab ${
            mode === 'login' ? 'auth-panel__tab--active' : ''
          }`}
          onClick={() => switchMode('login')}
          disabled={isAuthenticating}
        >
          Log in
        </button>
        <button
          type="button"
          className={`auth-panel__tab ${
            mode === 'signup' ? 'auth-panel__tab--active' : ''
          }`}
          onClick={() => switchMode('signup')}
          disabled={isAuthenticating}
        >
          Sign up
        </button>
      </div>

      {mode === 'signup' ? (
        <form className="auth-form" onSubmit={handleSignupSubmit}>
          <h2>Create an account</h2>
          <p className="auth-form__hint">
            Register to manage projects, assign tasks, and collaborate with your team.
          </p>

          <label className="auth-form__field">
            <span>Name</span>
            <input
              type="text"
              value={signupForm.name}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setSignupForm((form) => ({
                  ...form,
                  name: event.target.value,
                }))
              }
              required
              placeholder="Ada Lovelace"
              disabled={isAuthenticating}
            />
          </label>

          <label className="auth-form__field">
            <span>Email</span>
            <input
              type="email"
              value={signupForm.email}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setSignupForm((form) => ({
                  ...form,
                  email: event.target.value,
                }))
              }
              required
              placeholder="ada@example.com"
              disabled={isAuthenticating}
            />
          </label>

          <label className="auth-form__field">
            <span>Password</span>
            <input
              type="password"
              value={signupForm.password}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setSignupForm((form) => ({
                  ...form,
                  password: event.target.value,
                }))
              }
              required
              placeholder="Minimum 8 characters"
              minLength={8}
              disabled={isAuthenticating}
            />
          </label>

          <label className="auth-form__field">
            <span>Confirm password</span>
            <input
              type="password"
              value={signupForm.passwordConfirmation}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setSignupForm((form) => ({
                  ...form,
                  passwordConfirmation: event.target.value,
                }))
              }
              required
              minLength={8}
              disabled={isAuthenticating}
            />
          </label>

          {(formError || auth.error) && (
            <p className="auth-form__error">{formError ?? auth.error}</p>
          )}

          <button
            type="submit"
            className="auth-form__submit"
            disabled={isAuthenticating}
          >
            {isAuthenticating ? 'Creating account…' : 'Create account'}
          </button>
        </form>
      ) : (
        <form className="auth-form" onSubmit={handleLoginSubmit}>
          <h2>Welcome back</h2>
          <p className="auth-form__hint">
            Sign in to view dashboards, track tasks, and monitor activity.
          </p>

          <label className="auth-form__field">
            <span>Email</span>
            <input
              type="email"
              value={loginForm.email}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setLoginForm((form) => ({
                  ...form,
                  email: event.target.value,
                }))
              }
              required
              placeholder="ada@example.com"
              disabled={isAuthenticating}
            />
          </label>

          <label className="auth-form__field">
            <span>Password</span>
            <input
              type="password"
              value={loginForm.password}
              maxLength={FIELD_MAX_LENGTH}
              onChange={(event) =>
                setLoginForm((form) => ({
                  ...form,
                  password: event.target.value,
                }))
              }
              required
              placeholder="••••••••"
              minLength={8}
              disabled={isAuthenticating}
            />
          </label>

          <label className="auth-form__checkbox">
            <input
              type="checkbox"
              checked={loginForm.rememberMe ?? false}
              onChange={(event) =>
                setLoginForm((form) => ({
                  ...form,
                  rememberMe: event.target.checked,
                }))
              }
              disabled={isAuthenticating}
            />
            <span>Keep me signed in</span>
          </label>

          {(formError || auth.error) && (
            <p className="auth-form__error">{formError ?? auth.error}</p>
          )}

          <button
            type="submit"
            className="auth-form__submit"
            disabled={isAuthenticating}
          >
            {isAuthenticating ? 'Signing in…' : 'Sign in'}
          </button>
        </form>
      )}
    </section>
  )
}

