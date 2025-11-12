import { useEffect, useMemo, useState } from 'react'
import type { TaskFormInput, TaskFormMode, TaskStatus, Project, User } from '../types'

const STATUS_OPTIONS: Array<{ label: string; value: TaskStatus }> = [
  { label: 'Pending', value: 'PENDING' },
  { label: 'In progress', value: 'IN_PROGRESS' },
  { label: 'Completed', value: 'COMPLETED' },
]

type TaskFormProps = {
  mode: TaskFormMode
  initialValues: TaskFormInput
  projects: Project[]
  users: User[]
  loading: boolean
  error?: string | null
  onSubmit: (values: TaskFormInput) => Promise<void> | void
  onCancel: () => void
}

export function TaskForm({
  mode,
  initialValues,
  projects,
  users,
  loading,
  error,
  onSubmit,
  onCancel,
}: TaskFormProps) {
  const [values, setValues] = useState<TaskFormInput>(initialValues)

  useEffect(() => {
    setValues(initialValues)
  }, [initialValues])

  const projectOptions = useMemo(() => projects.map((project) => ({
    label: project.name,
    value: project.id,
  })), [projects])

  const userOptions = useMemo(() => users.map((user) => ({
    label: user.name,
    value: user.id,
  })), [users])

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    await onSubmit(values)
  }

  return (
    <form className="task-form" onSubmit={handleSubmit}>
      <div className="task-form__grid">
        <label className="task-form__field">
          <span>Title</span>
          <input
            type="text"
            value={values.title}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                title: event.target.value,
              }))
            }
            placeholder="Outline Q1 goals"
            required
            maxLength={120}
            disabled={loading}
          />
        </label>

        <label className="task-form__field">
          <span>Project</span>
          <select
            value={values.projectId}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                projectId: event.target.value,
              }))
            }
            required
            disabled={loading || projectOptions.length === 0}
          >
            {projectOptions.length === 0 ? (
              <option value="">No projects available</option>
            ) : null}
            {projectOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>

        <label className="task-form__field">
          <span>Status</span>
          <select
            value={values.status}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                status: event.target.value as TaskStatus,
              }))
            }
            disabled={loading}
          >
            {STATUS_OPTIONS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>

        <label className="task-form__field">
          <span>Assignee</span>
          <select
            value={values.assigneeId ?? ''}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                assigneeId: event.target.value ? event.target.value : null,
              }))
            }
            disabled={loading || userOptions.length === 0}
          >
            <option value="">Unassigned</option>
            {userOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>

        <label className="task-form__field">
          <span>Due date</span>
          <input
            type="date"
            value={values.dueAt ? values.dueAt.slice(0, 10) : ''}
            onChange={(event) =>
              setValues((draft) => ({
                ...draft,
                dueAt: event.target.value ? `${event.target.value}T00:00:00Z` : undefined,
              }))
            }
            disabled={loading}
          />
        </label>
      </div>

      <label className="task-form__field">
        <span>Description</span>
        <textarea
          value={values.description ?? ''}
          onChange={(event) =>
            setValues((draft) => ({
              ...draft,
              description: event.target.value,
            }))
          }
          placeholder="Optional additional context"
          rows={4}
          maxLength={1000}
          disabled={loading}
        />
      </label>

      {error ? <p className="task-form__error">{error}</p> : null}

      <div className="task-form__actions">
        <button
          type="button"
          className="task-form__button task-form__button--secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="task-form__button task-form__button--primary"
          disabled={loading}
        >
          {loading ? 'Saving…' : mode === 'create' ? 'Create task' : 'Save changes'}
        </button>
      </div>
    </form>
  )
}

