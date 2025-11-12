import type { ProjectSummary } from '../types'

type ProjectListProps = {
  projects: ProjectSummary[]
  loading: boolean
  onEdit: (projectId: string) => void
  onDelete: (projectId: string) => void
  deletingId?: string | null
}

export function ProjectList({
  projects,
  loading,
  onEdit,
  onDelete,
  deletingId,
}: ProjectListProps) {
  if (loading) {
    return <p className="projects__status">Loading projects…</p>
  }

  if (!projects.length) {
    return <p className="projects__status">No projects found. Create your first one to get started.</p>
  }

  return (
    <div className="dashboard-table__wrapper projects-table__wrapper">
      <table className="dashboard-table projects-table">
        <thead>
          <tr>
            <th scope="col">Project</th>
            <th scope="col">Description</th>
            <th scope="col" className="dashboard-table__numeric">
              Tasks
            </th>
            <th scope="col" className="dashboard-table__actions">
              Actions
            </th>
          </tr>
        </thead>
        <tbody>
          {projects.map((project) => {
            const isDeleting = deletingId === project.id
            return (
              <tr key={project.id}>
                <td>
                  <strong>{project.name}</strong>
                </td>
                <td className="dashboard-table__muted">
                  {project.description?.trim().length
                    ? project.description
                    : 'No description provided'}
                </td>
                <td className="dashboard-table__numeric">
                  {project.taskCount}
                </td>
                <td className="dashboard-table__actions">
                  <button
                    type="button"
                    className="dashboard-table__action dashboard-table__action--edit"
                    onClick={() => onEdit(project.id)}
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    className="dashboard-table__action dashboard-table__action--delete"
                    onClick={() => onDelete(project.id)}
                    disabled={isDeleting}
                  >
                    {isDeleting ? 'Deleting…' : 'Delete'}
                  </button>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

