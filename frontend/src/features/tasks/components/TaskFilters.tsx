import { type ChangeEvent } from 'react'
import { useAppDispatch, useAppSelector } from '../../../app/hooks'
import {
  resetFilters,
  setProjectFilter,
  setSearch,
  setStatusFilter,
} from '../tasksSlice'
import type { StatusFilter } from '../tasksSlice'
import type { Project, TaskStatus } from '../types'

const STATUS_OPTIONS: Array<{ label: string; value: StatusFilter }> = [
  { label: 'All statuses', value: 'ALL' },
  { label: 'Pending', value: 'PENDING' },
  { label: 'In progress', value: 'IN_PROGRESS' },
  { label: 'Completed', value: 'COMPLETED' },
]

type TaskFiltersProps = {
  projects: Project[]
}

export function TaskFilters({ projects }: TaskFiltersProps) {
  const dispatch = useAppDispatch()
  const { projectId, status, search } = useAppSelector((state) => state.tasks)

  const handleStatusChange = (event: ChangeEvent<HTMLSelectElement>) => {
    dispatch(setStatusFilter(event.target.value as TaskStatus | 'ALL'))
  }

  const handleProjectChange = (event: ChangeEvent<HTMLSelectElement>) => {
    const value = event.target.value
    dispatch(setProjectFilter(value === 'ALL' ? null : value))
  }

  const handleSearchChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch(setSearch(event.target.value))
  }

  return (
    <section className="filters">
      <div className="filter-group">
        <label htmlFor="status-filter">Status</label>
        <select id="status-filter" value={status} onChange={handleStatusChange}>
          {STATUS_OPTIONS.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </div>

      <div className="filter-group">
        <label htmlFor="project-filter">Project</label>
        <select
          id="project-filter"
          value={projectId ?? 'ALL'}
          onChange={handleProjectChange}
        >
          <option value="ALL">All projects</option>
          {projects.map((project) => (
            <option key={project.id} value={project.id}>
              {project.name}
            </option>
          ))}
        </select>
      </div>

      <div className="filter-group search">
        <label htmlFor="task-search">Search</label>
        <input
          id="task-search"
          type="search"
          value={search}
          onChange={handleSearchChange}
          placeholder="Search tasks"
        />
      </div>

      <button type="button" className="reset-button" onClick={() => dispatch(resetFilters())}>
        Reset
      </button>
    </section>
  )
}

