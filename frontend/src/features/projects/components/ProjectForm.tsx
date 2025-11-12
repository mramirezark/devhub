import { useEffect, useState } from 'react'
import type { ProjectInput, ProjectFormMode } from '../types'

type ProjectFormProps = {
  mode: ProjectFormMode
  initialValues: ProjectInput
  loading: boolean
  onSubmit: (values: ProjectInput) => Promise<void> | void
  onCancel: () => void
  error?: string | null
}

export function ProjectForm({
  mode,
  initialValues,
  loading,
  onSubmit,
  onCancel,
  error,
}: ProjectFormProps) {
  const [values, setValues] = useState<ProjectInput>(initialValues)

  useEffect(() => {
    setValues(initialValues)
  }, [initialValues])

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    await onSubmit(values)
  }

  return (
    <form className="project-form" onSubmit={handleSubmit}>
      <div className="project-form__fields">
        <label className="project-form__field">
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
            placeholder="Marketing Website Redesign"
            required
            maxLength={80}
            disabled={loading}
          />
        </label>

        <label className="project-form__field">
          <span>Description</span>
          <textarea
            value={values.description ?? ''}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                description: event.target.value,
              }))
            }
            placeholder="Optional brief summary of the project goals."
            maxLength={500}
            rows={3}
            disabled={loading}
          />
        </label>
      </div>

      {error ? <p className="project-form__error">{error}</p> : null}

      <div className="project-form__actions">
        <button
          type="button"
          className="project-form__button project-form__button--secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="project-form__button project-form__button--primary"
          disabled={loading}
        >
          {loading ? 'Saving…' : mode === 'create' ? 'Create project' : 'Save changes'}
        </button>
      </div>
    </form>
  )
}

