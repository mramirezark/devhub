type ProjectToolbarProps = {
  onCreate: () => void
  totalProjects: number
}

export function ProjectToolbar({ onCreate, totalProjects }: ProjectToolbarProps) {
  return (
    <header className="projects__header">
      <div>
        <h2>Projects</h2>
        <p className="projects__subtitle">
          Manage the initiatives your tasks belong to. {totalProjects} project
          {totalProjects === 1 ? '' : 's'} available.
        </p>
      </div>
      <button type="button" className="projects__create-button" onClick={onCreate}>
        New project
      </button>
    </header>
  )
}

