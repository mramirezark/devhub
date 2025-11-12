import { Fragment } from 'react'
import { useAppSelector } from '../../../app/hooks'
import type { Task } from '../types'
import { TaskActivityTimeline } from './TaskActivityTimeline'

type TaskListProps = {
  tasks: Task[]
  onEdit: (taskId: string) => void
  onDelete: (taskId: string) => void
  deletingId?: string | null
}

const STATUS_LABELS: Record<Task['status'], string> = {
  PENDING: 'Pending',
  IN_PROGRESS: 'In progress',
  COMPLETED: 'Completed',
}

export function TaskList({ tasks, onEdit, onDelete, deletingId }: TaskListProps) {
  const { showActivities } = useAppSelector((state) => state.tasks)

  if (!tasks.length) {
    return <p className="empty-state">No tasks match the current filters.</p>
  }

  return (
    <div className="dashboard-table__wrapper tasks-table__wrapper">
      <table className="dashboard-table tasks-table">
        <thead>
          <tr>
            <th scope="col">Task</th>
            <th scope="col">Status</th>
            <th scope="col">Project</th>
            <th scope="col">Assignee</th>
            <th scope="col">Due</th>
            <th scope="col" className="dashboard-table__actions">
              Actions
            </th>
          </tr>
        </thead>
        <tbody>
          {tasks.map((task) => {
            const isDeleting = deletingId === task.id
            const statusClass = `status status--${task.status.toLowerCase()}`

            return (
              <Fragment key={task.id}>
                <tr>
                  <td>
                    <strong>{task.title}</strong>
                    {task.description ? (
                      <p className="dashboard-table__muted">{task.description}</p>
                    ) : null}
                  </td>
                  <td>
                    <span className={statusClass}>{STATUS_LABELS[task.status]}</span>
                  </td>
                  <td>{task.project.name}</td>
                  <td>{task.assignee ? task.assignee.name : '—'}</td>
                  <td>
                    {task.dueAt ? new Date(task.dueAt).toLocaleDateString() : '—'}
                  </td>
                  <td className="dashboard-table__actions">
                    <button
                      type="button"
                      className="dashboard-table__action dashboard-table__action--edit"
                      onClick={() => onEdit(task.id)}
                    >
                      Edit
                    </button>
                    <button
                      type="button"
                      className="dashboard-table__action dashboard-table__action--delete"
                      onClick={() => onDelete(task.id)}
                      disabled={isDeleting}
                    >
                      {isDeleting ? 'Deleting…' : 'Delete'}
                    </button>
                  </td>
                </tr>
                {showActivities ? (
                  <tr key={`${task.id}-activities`}>
                    <td colSpan={6} className="tasks-table__activities">
                      <h3>Recent activity</h3>
                      <TaskActivityTimeline activities={task.activities} />
                    </td>
                  </tr>
                ) : null}
              </Fragment>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

