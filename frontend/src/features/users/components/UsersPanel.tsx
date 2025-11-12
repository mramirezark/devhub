import { useEffect, useMemo, useState } from 'react'
import { useQuery, useMutation } from '@apollo/client/react'
import { useAppDispatch, useAppSelector } from '../../../app/hooks'
import { Modal } from '../../../components'
import { USERS_QUERY, CREATE_USER_MUTATION, UPDATE_USER_MUTATION, DELETE_USER_MUTATION } from '../graphql'
import type {
  CreateUserResponse,
  DeleteUserResponse,
  UpdateUserResponse,
  UserFormInput,
  UserSummary,
  UsersQueryResponse,
} from '../types'
import { UserToolbar } from './UserToolbar'
import { UserForm } from './UserForm'
import { UserList } from './UserList'
import { closeUserForm, openUserCreateForm, openUserEditForm } from '../usersSlice'

export function UsersPanel() {
  const dispatch = useAppDispatch()
  const uiState = useAppSelector((state) => state.usersUi)

  const { data, loading, error, refetch } = useQuery<UsersQueryResponse>(USERS_QUERY, {
    fetchPolicy: 'cache-and-network',
  })

  const [createUserMutation] = useMutation<CreateUserResponse>(CREATE_USER_MUTATION)
  const [updateUserMutation] = useMutation<UpdateUserResponse>(UPDATE_USER_MUTATION)
  const [deleteUserMutation] = useMutation<DeleteUserResponse>(DELETE_USER_MUTATION)

  const [formError, setFormError] = useState<string | null>(null)
  const [isMutating, setIsMutating] = useState(false)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<UserSummary | null>(null)

  useEffect(() => {
    if (!uiState.isFormOpen) {
      setFormError(null)
    }
  }, [uiState.isFormOpen])

useEffect(() => {
  if (!deleteTarget) {
    setFormError(null)
  }
}, [deleteTarget])

  const users = useMemo<UserSummary[]>(() => data?.users ?? [], [data?.users])
  const editingUser = useMemo(
    () => users.find((user) => user.id === uiState.editingUserId),
    [users, uiState.editingUserId],
  )

  const initialFormValues: UserFormInput = useMemo(() => {
    if (!uiState.isFormOpen || uiState.mode === 'create') {
      return {
        name: '',
        email: '',
        password: '',
        passwordConfirmation: '',
        admin: false,
      }
    }

    if (!editingUser) {
      return {
        name: '',
        email: '',
        password: '',
        passwordConfirmation: '',
        admin: false,
      }
    }

    return {
      name: editingUser.name,
      email: editingUser.email,
      admin: editingUser.admin,
    }
  }, [uiState.isFormOpen, uiState.mode, editingUser])

  const handleCreateClick = () => {
    dispatch(openUserCreateForm())
  }

  const handleEdit = (userId: string) => {
    dispatch(openUserEditForm(userId))
  }

  const handleRequestDelete = (userId: string) => {
    const target = users.find((user) => user.id === userId)
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
      const result = await deleteUserMutation({
        variables: { id: deleteTarget.id },
      })
      const payload = result.data?.deleteUser
      if (payload?.errors?.length) {
        setFormError(payload.errors.join(', '))
      } else {
        await refetch()
        setDeleteTarget(null)
      }
    } catch (mutationError) {
      const message =
        mutationError instanceof Error ? mutationError.message : 'Unable to delete user'
      setFormError(message)
    } finally {
      setDeletingId(null)
    }
  }

  const handleFormSubmit = async (values: UserFormInput) => {
    setIsMutating(true)
    setFormError(null)

    try {
      if (uiState.mode === 'create') {
        const result = await createUserMutation({
          variables: {
            name: values.name,
            email: values.email,
            password: values.password,
            passwordConfirmation: values.passwordConfirmation,
            admin: values.admin,
          },
        })
        const payload = result.data?.createUser
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }
      } else if (uiState.editingUserId) {
        const result = await updateUserMutation({
          variables: {
            id: uiState.editingUserId,
            name: values.name,
            email: values.email,
            admin: values.admin,
          },
        })
        const payload = result.data?.updateUser
        if (payload?.errors?.length) {
          setFormError(payload.errors.join(', '))
          return
        }
      }

      await refetch()
      dispatch(closeUserForm())
    } catch (mutationError) {
      const message =
        mutationError instanceof Error ? mutationError.message : 'Unable to save user'
      setFormError(message)
    } finally {
      setIsMutating(false)
    }
  }

  return (
    <section className="users">
      <UserToolbar onCreate={handleCreateClick} totalUsers={users.length} />

      {formError && !uiState.isFormOpen && !deleteTarget ? (
        <p className="users__status users__status--error">{formError}</p>
      ) : null}

      {error ? (
        <p className="users__status users__status--error">{error.message}</p>
      ) : null}

      {loading ? (
        <p className="users__status">Loading users…</p>
      ) : (
        <UserList users={users} onEdit={handleEdit} onDelete={handleRequestDelete} deletingId={deletingId} />
      )}

      <Modal
        open={uiState.isFormOpen}
        onClose={() => dispatch(closeUserForm())}
        title={uiState.mode === 'create' ? 'Invite User' : 'Edit User'}
        size="md"
      >
        <UserForm
          mode={uiState.mode}
          initialValues={initialFormValues}
          loading={isMutating}
          error={formError}
          onSubmit={handleFormSubmit}
          onCancel={() => dispatch(closeUserForm())}
        />
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Remove user"
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
              {deletingId ? 'Removing…' : 'Delete'}
            </button>
          </div>
        }
      >
        <p>
          Are you sure you want to remove <strong>{deleteTarget?.name ?? 'this user'}</strong>? They
          will lose access immediately.
        </p>
        {formError ? <p className="modal__error">{formError}</p> : null}
      </Modal>
    </section>
  )
}

