import { useEffect, useState } from 'react'
import type { UserFormInput, UserFormMode } from '../types'

type UserFormProps = {
  mode: UserFormMode
  initialValues: UserFormInput
  loading: boolean
  error?: string | null
  onSubmit: (values: UserFormInput) => Promise<void> | void
  onCancel: () => void
}

export function UserForm({
  mode,
  initialValues,
  loading,
  error,
  onSubmit,
  onCancel,
}: UserFormProps) {
  const [values, setValues] = useState<UserFormInput>(initialValues)
  const [formError, setFormError] = useState<string | null>(null)

  useEffect(() => {
    setValues(initialValues)
    setFormError(null)
  }, [initialValues])

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setFormError(null)

    if (mode === 'create') {
      if (!values.password || values.password.length < 8) {
        setFormError('Password must be at least 8 characters')
        return
      }

      if (values.password !== values.passwordConfirmation) {
        setFormError('Passwords do not match')
        return
      }
    }

    await onSubmit(values)
  }

  return (
    <form className="user-form" onSubmit={handleSubmit}>
      <div className="user-form__grid">
        <label className="user-form__field">
          <span>Name</span>
          <input
            type="text"
            value={values.name}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                name: event.target.value,
              }))
            }
            placeholder="Grace Hopper"
            required
            maxLength={80}
            disabled={loading}
          />
        </label>

        <label className="user-form__field">
          <span>Email</span>
          <input
            type="email"
            value={values.email}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                email: event.target.value,
              }))
            }
            placeholder="grace@example.com"
            required
            maxLength={120}
            disabled={loading}
          />
        </label>

        <label className="user-form__checkbox">
          <input
            type="checkbox"
            checked={values.admin}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                admin: event.target.checked,
              }))
            }
            disabled={loading}
          />
          <span>Is Admin</span>
        </label>

        {mode === 'create' ? (
          <>
            <label className="user-form__field">
              <span>Password</span>
              <input
                type="password"
                value={values.password ?? ''}
                onChange={(event) =>
                  setValues((draft) => ({
                    ...draft,
                    password: event.target.value,
                  }))
                }
                placeholder="Minimum 8 characters"
                minLength={8}
                required
                disabled={loading}
              />
            </label>

            <label className="user-form__field">
              <span>Confirm password</span>
              <input
                type="password"
                value={values.passwordConfirmation ?? ''}
                onChange={(event) =>
                  setValues((draft) => ({
                    ...draft,
                    passwordConfirmation: event.target.value,
                  }))
                }
                placeholder="Repeat password"
                minLength={8}
                required
                disabled={loading}
              />
            </label>
          </>
        ) : null}
      </div>

      {(formError || error) ? (
        <p className="user-form__error">{formError ?? error}</p>
      ) : null}

      <div className="user-form__actions">
        <button
          type="button"
          className="user-form__button user-form__button--secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="user-form__button user-form__button--primary"
          disabled={loading}
        >
          {loading ? 'Saving…' : mode === 'create' ? 'Create user' : 'Save changes'}
        </button>
      </div>
    </form>
  )
}

