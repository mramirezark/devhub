import { useEffect, useMemo, useState } from 'react'
import { useQuery, useMutation } from '@apollo/client/react'
import { useAppDispatch, useAppSelector } from '../../../app/hooks'
import { Modal } from '../../../components'
import { ProjectForm } from './ProjectForm'
import { ProjectToolbar } from './ProjectToolbar'
import { ProjectList } from './ProjectList'
import {
  CREATE_PROJECT_MUTATION,
  DELETE_PROJECT_MUTATION,
  PROJECTS_QUERY,
  UPDATE_PROJECT_MUTATION,
} from '../graphql'
import type {
  CreateProjectResponse,
  DeleteProjectResponse,
  ProjectInput,
  ProjectSummary,
  ProjectsQueryResponse,
  UpdateProjectResponse,
} from '../types'
import { closeForm, openCreateForm, openEditForm } from '../projectsSlice'

export function ProjectsPanel() {
  const dispatch = useAppDispatch()
  const uiState = useAppSelector((state) => state.projectsUi)

  const { data, loading, error, refetch } = useQuery<ProjectsQueryResponse>(PROJECTS_QUERY, {
    fetchPolicy: 'cache-and-network',
    variables: { first: 100 }, // Request up to 100 items per page
  })

  const [createProject] = useMutation<CreateProjectResponse>(CREATE_PROJECT_MUTATION)
  const [updateProject] = useMutation<UpdateProjectResponse>(UPDATE_PROJECT_MUTATION)
  const [deleteProject] = useMutation<DeleteProjectResponse>(DELETE_PROJECT_MUTATION)

  const [formError, setFormError] = useState<string | null>(null)
  const [isMutating, setIsMutating] = useState(false)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<ProjectSummary | null>(null)

  useEffect(() => {
    if (!uiState.isFormOpen) {
      setFormError(null)
    }
  }, [uiState.isFormOpen])

  const projects: ProjectSummary[] = useMemo(() => {
    if (!data?.projects?.nodes) return []
    return data.projects.nodes.map((project) => ({
      id: project.id,
      name: project.name,
      description: project.description,
      taskCount: project.tasks.length,
    }))
  }, [data?.projects])

  const initialFormValues: ProjectInput = useMemo(() => {
    if (!uiState.isFormOpen || uiState.mode === 'create') {
      return { name: '', description: '' }
    }

    const project = projects.find((item) => item.id === uiState.editingProjectId)
    if (!project) {
      return { name: '', description: '' }
    }
    return {
      name: project.name,
      description: project.description ?? '',
    }
  }, [uiState.isFormOpen, uiState.mode, uiState.editingProjectId, projects])

  const handleCreate = () => {
    dispatch(openCreateForm())
  }

  const handleEdit = (projectId: string) => {
    dispatch(openEditForm(projectId))
  }

  const handleRequestDelete = (projectId: string) => {
    const target = projects.find((item) => item.id === projectId)
    if (target) {
      setDeleteTarget(target)
      setFormError(null)
    }
  }

  const handleConfirmDelete = async () => {
    if (!deleteTarget) return

    setDeletingId(deleteTarget.id)
    setFormError(null)

    try {
      const result = await deleteProject({
        variables: { id: deleteTarget.id },
      })
      const deleteResult = result.data?.deleteProject
      if (deleteResult && deleteResult.errors.length > 0) {
        setFormError(deleteResult.errors.join(', '))
      } else {
        await refetch()
        setDeleteTarget(null)
      }
    } catch (mutationError) {
      const message =
        mutationError instanceof Error
          ? mutationError.message
          : 'Unable to delete project'
      setFormError(message)
    } finally {
      setDeletingId(null)
    }
  }

  const handleFormSubmit = async (values: ProjectInput) => {
    setIsMutating(true)
    setFormError(null)

    try {
      if (uiState.mode === 'create') {
        const result = await createProject({
          variables: { name: values.name, description: values.description || null },
        })
        const payload = result.data?.createProject
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }
      } else if (uiState.editingProjectId) {
        const result = await updateProject({
          variables: {
            id: uiState.editingProjectId,
            name: values.name,
            description: values.description || null,
          },
        })
        const payload = result.data?.updateProject
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }
      }

      await refetch()
      dispatch(closeForm())
    } catch (mutationError) {
      const message =
        mutationError instanceof Error
          ? mutationError.message
          : 'Unable to save project'
      setFormError(message)
    } finally {
      setIsMutating(false)
    }
  }

  return (
    <section className="projects">
      <ProjectToolbar onCreate={handleCreate} totalProjects={projects.length} />

      {error ? <p className="projects__status projects__status--error">{error.message}</p> : null}

      <ProjectList
        projects={projects}
        loading={loading}
        onEdit={handleEdit}
        onDelete={handleRequestDelete}
        deletingId={deletingId}
      />

      <Modal
        open={uiState.isFormOpen}
        onClose={() => dispatch(closeForm())}
        title={uiState.mode === 'create' ? 'Create Project' : 'Edit Project'}
        size="md"
      >
        <ProjectForm
          mode={uiState.mode}
          initialValues={initialFormValues}
          loading={isMutating}
          onSubmit={handleFormSubmit}
          onCancel={() => dispatch(closeForm())}
          error={formError}
        />
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete project"
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
              onClick={handleConfirmDelete}
              disabled={Boolean(deletingId)}
            >
              {deletingId ? 'Deleting…' : 'Delete'}
            </button>
          </div>
        }
      >
        <p>
          Are you sure you want to delete{' '}
          <strong>{deleteTarget?.name ?? 'this project'}</strong>? This action
          cannot be undone.
        </p>
        {formError ? <p className="modal__error">{formError}</p> : null}
      </Modal>
    </section>
  )
}

