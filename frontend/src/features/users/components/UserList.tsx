import type { UserSummary } from '../types'

type UserListProps = {
  users: UserSummary[]
  onEdit: (userId: string) => void
  onDelete: (userId: string) => void
  deletingId?: string | null
}

export function UserList({ users, onEdit, onDelete, deletingId }: UserListProps) {
  if (!users.length) {
    return <p className="users__status">No users found.</p>
  }

  return (
    <div className="dashboard-table__wrapper users-table__wrapper">
      <table className="dashboard-table users-table">
        <thead>
          <tr>
            <th scope="col">Name</th>
            <th scope="col">Email</th>
            <th scope="col">Role</th>
            <th scope="col" className="users-table__actions-col">
              Actions
            </th>
          </tr>
        </thead>
        <tbody>
          {users.map((user) => {
            const isDeleting = deletingId === user.id
            return (
              <tr key={user.id}>
                <td>{user.name}</td>
                <td>{user.email}</td>
                <td>{user.admin ? 'Administrator' : 'Member'}</td>
                <td className="dashboard-table__actions users-table__actions">
                  <button
                    type="button"
                    className="dashboard-table__action dashboard-table__action--edit"
                    onClick={() => onEdit(user.id)}
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    className="dashboard-table__action dashboard-table__action--delete"
                    onClick={() => onDelete(user.id)}
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

