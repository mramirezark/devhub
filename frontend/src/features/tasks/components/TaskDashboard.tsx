import { useEffect, useMemo, useState } from 'react'
import { useQuery, useMutation } from '@apollo/client/react'
import {
  TASK_DASHBOARD_QUERY,
  CREATE_TASK_MUTATION,
  UPDATE_TASK_MUTATION,
  DELETE_TASK_MUTATION,
  ASSIGN_TASK_TO_USER_MUTATION,
} from '../graphql'
import { useAppDispatch, useAppSelector } from '../../../app/hooks'
import { Modal } from '../../../components'
import type {
  Task,
  TasksResponse,
  TaskStatus,
  TaskFormInput,
  CreateTaskResponse,
  UpdateTaskResponse,
  DeleteTaskResponse,
  AssignTaskResponse,
  Project,
  User,
} from '../types'
import { TaskFilters } from './TaskFilters'
import { TaskList } from './TaskList'
import { TaskForm } from './TaskForm'
import {
  toggleShowActivities,
  openTaskCreateForm,
  openTaskEditForm,
  closeTaskForm,
} from '../tasksSlice'

export function TaskDashboard() {
  const dispatch = useAppDispatch()
  const taskUi = useAppSelector((state) => state.tasks)
  const isAuthenticated =
    useAppSelector((state) => state.auth.status === 'authenticated')

  const variables = useMemo(
    () => ({
      status: taskUi.status === 'ALL' ? undefined : taskUi.status,
      projectId: taskUi.projectId ?? undefined,
    }),
    [taskUi.status, taskUi.projectId],
  )

  const { data, loading, error, refetch } = useQuery<TasksResponse>(
    TASK_DASHBOARD_QUERY,
    {
      variables,
      fetchPolicy: 'cache-and-network',
      skip: !isAuthenticated,
    },
  )

  const projects = (data?.projects ?? []) as Project[]
  const users = (data?.assignableUsers ?? []) as User[]
  const tasks = data?.tasks ?? []

  const [createTaskMutation] = useMutation<CreateTaskResponse>(CREATE_TASK_MUTATION)
  const [updateTaskMutation] = useMutation<UpdateTaskResponse>(UPDATE_TASK_MUTATION)
  const [deleteTaskMutation] = useMutation<DeleteTaskResponse>(DELETE_TASK_MUTATION)
  const [assignTaskMutation] = useMutation<AssignTaskResponse>(
    ASSIGN_TASK_TO_USER_MUTATION,
  )

  const [formError, setFormError] = useState<string | null>(null)
const [deleteError, setDeleteError] = useState<string | null>(null)
  const [isMutating, setIsMutating] = useState(false)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Task | null>(null)

  useEffect(() => {
    if (!taskUi.isFormOpen) {
      setFormError(null)
    }
  }, [taskUi.isFormOpen])

  useEffect(() => {
    if (!deleteTarget) {
      setDeleteError(null)
    }
  }, [deleteTarget])

  const filteredTasks = useMemo(() => {
    if (!tasks.length) return []
    const trimmed = taskUi.search.trim().toLowerCase()
    if (!trimmed) return tasks

    return tasks.filter((task: Task) => {
      const haystack = [
        task.title,
        task.description ?? '',
        task.project.name,
        task.assignee?.name ?? '',
      ]
        .join(' ')
        .toLowerCase()

      return haystack.includes(trimmed)
    })
  }, [tasks, taskUi.search])

  type SummaryKey = 'total' | TaskStatus

  const statusSummary = useMemo<Record<SummaryKey, number>>(() => {
    return filteredTasks.reduce<Record<SummaryKey, number>>(
      (acc, task) => {
        acc.total += 1
        acc[task.status] = (acc[task.status] ?? 0) + 1
        return acc
      },
      {
        total: 0,
        PENDING: 0,
        IN_PROGRESS: 0,
        COMPLETED: 0,
      },
    )
  }, [filteredTasks])

  const editingTask = useMemo(
    () => tasks.find((task) => task.id === taskUi.editingTaskId),
    [tasks, taskUi.editingTaskId],
  )

  const defaultProjectId =
    taskUi.projectId ?? editingTask?.project.id ?? projects[0]?.id ?? ''
  const canCreateTask = projects.length > 0

  const initialFormValues: TaskFormInput = useMemo(() => {
    if (!taskUi.isFormOpen || taskUi.formMode === 'create') {
      return {
        projectId: defaultProjectId,
        title: '',
        description: '',
        status: 'PENDING',
        assigneeId: null,
        dueAt: undefined,
      }
    }

    if (!editingTask) {
      return {
        projectId: defaultProjectId,
        title: '',
        description: '',
        status: 'PENDING',
        assigneeId: null,
        dueAt: undefined,
      }
    }

    return {
      projectId: editingTask.project.id,
      title: editingTask.title,
      description: editingTask.description ?? '',
      status: editingTask.status,
      assigneeId: editingTask.assignee?.id ?? null,
      dueAt: editingTask.dueAt ?? undefined,
    }
  }, [taskUi.isFormOpen, taskUi.formMode, editingTask, defaultProjectId])

  const handleOpenCreate = () => {
    if (!canCreateTask) return
    dispatch(openTaskCreateForm())
  }

  const handleEditTask = (taskId: string) => {
    dispatch(openTaskEditForm(taskId))
  }

  const handleRequestDeleteTask = (taskId: string) => {
    const target = tasks.find((taskItem) => taskItem.id === taskId)
    if (target) {
      setDeleteTarget(target)
      setDeleteError(null)
    }
  }

  const handleConfirmDeleteTask = async () => {
    if (!deleteTarget) return

    setDeletingId(deleteTarget.id)
    setDeleteError(null)
    try {
      const result = await deleteTaskMutation({ variables: { id: deleteTarget.id } })
      const payload = result.data?.deleteTask
      if (payload?.errors?.length) {
        setDeleteError(payload.errors.join(', '))
      } else {
        await refetch()
        setDeleteTarget(null)
      }
    } catch (mutationError) {
      const message =
        mutationError instanceof Error
          ? mutationError.message
          : 'Unable to delete task'
      setDeleteError(message)
    } finally {
      setDeletingId(null)
    }
  }

  const handleFormSubmit = async (input: TaskFormInput) => {
    setIsMutating(true)
    setFormError(null)

    const assignIfNeeded = async (taskId: string) => {
      if (!input.assigneeId) return
      const response = await assignTaskMutation({
        variables: { taskId, userId: input.assigneeId },
      })
      const payload = response.data?.assignTaskToUser
      if (payload?.errors?.length) {
        throw new Error(payload.errors.join(', '))
      }
    }

    try {
      if (taskUi.formMode === 'create') {
        const result = await createTaskMutation({
          variables: {
            projectId: input.projectId,
            title: input.title,
            description: input.description || null,
            status: input.status,
            dueAt: input.dueAt,
          },
        })
        const payload = result.data?.createTask
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }

        const newTaskId = payload?.task?.id
        if (newTaskId) {
          await assignIfNeeded(newTaskId)
        }
      } else if (taskUi.editingTaskId) {
        const result = await updateTaskMutation({
          variables: {
            id: taskUi.editingTaskId,
            title: input.title,
            description: input.description || null,
            status: input.status,
            dueAt: input.dueAt,
          },
        })
        const payload = result.data?.updateTask
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }

        await assignIfNeeded(taskUi.editingTaskId)
      }

      await refetch()
      dispatch(closeTaskForm())
    } catch (mutationError) {
      const message =
        mutationError instanceof Error
          ? mutationError.message
          : 'Unable to save task'
      setFormError(message)
    } finally {
      setIsMutating(false)
    }
  }

  if (!isAuthenticated) {
    return null
  }

  return (
    <section className="dashboard">
      <header className="dashboard__header">
        <div>
          <h1>Tasks</h1>
          <p className="dashboard__subtitle">
            Monitor task assignments, status changes, and recent activity sourced from the Rails GraphQL API.
          </p>
        </div>
        <div className="dashboard__actions">
          <button
            type="button"
            className="toggle-activities"
            onClick={() => dispatch(toggleShowActivities())}
          >
            {taskUi.showActivities ? 'Hide activity timelines' : 'Show activity timelines'}
          </button>
          <button
            type="button"
            className="tasks__create-button"
            onClick={handleOpenCreate}
            disabled={!canCreateTask}
          >
            New task
          </button>
        </div>
      </header>

      <section className="summary-cards">
        <article>
          <h2>Total</h2>
          <p>{statusSummary.total}</p>
        </article>
        <article>
          <h2>Pending</h2>
          <p>{statusSummary.PENDING}</p>
        </article>
        <article>
          <h2>In progress</h2>
          <p>{statusSummary.IN_PROGRESS}</p>
        </article>
        <article>
          <h2>Completed</h2>
          <p>{statusSummary.COMPLETED}</p>
        </article>
      </section>

      <TaskFilters projects={projects} />

      {!canCreateTask ? (
        <p className="tasks__status tasks__status--info">
          No projects found. Create a project before adding tasks.
        </p>
      ) : null}

      {taskUi.isFormOpen ? (
        <TaskForm
          mode={taskUi.formMode}
          initialValues={initialFormValues}
          projects={projects}
          users={users}
          loading={isMutating}
          error={formError}
          onSubmit={handleFormSubmit}
          onCancel={() => dispatch(closeTaskForm())}
        />
      ) : null}

      {loading ? <p>Loading tasks…</p> : null}
      {error ? (
        <p className="error">
          Unable to load tasks. {error.message}
        </p>
      ) : null}

      {!loading && !error ? (
        <TaskList
          tasks={filteredTasks}
          onEdit={handleEditTask}
          onDelete={handleRequestDeleteTask}
          deletingId={deletingId}
        />
      ) : null}

      <Modal
        open={taskUi.isFormOpen}
        onClose={() => dispatch(closeTaskForm())}
        title={taskUi.formMode === 'create' ? 'Create Task' : 'Edit Task'}
        size="lg"
      >
        <TaskForm
          mode={taskUi.formMode}
          initialValues={initialFormValues}
          projects={projects}
          users={users}
          loading={isMutating}
          error={formError}
          onSubmit={handleFormSubmit}
          onCancel={() => dispatch(closeTaskForm())}
        />
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete task"
        size="sm"
        footer={
          <div className="modal__confirm-actions">
            <button
              type="button"
              className="modal__button modal__button--secondary"
              onClick={() => setDeleteTarget(null)}
              disabled={Boolean(deletingId)}
            >
              Cancel
            </button>
            <button
              type="button"
              className="modal__button modal__button--danger"
              onClick={handleConfirmDeleteTask}
              disabled={Boolean(deletingId)}
            >
              {deletingId ? 'Deleting…' : 'Delete'}
            </button>
          </div>
        }
      >
        <p>
          Are you sure you want to delete <strong>{deleteTarget?.title ?? 'this task'}</strong>? Any
          associated activity will also be removed.
        </p>
        {deleteError ? <p className="modal__error">{deleteError}</p> : null}
      </Modal>
    </section>
  )
}
