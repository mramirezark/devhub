type UserToolbarProps = {
  onCreate: () => void
  totalUsers: number
}

export function UserToolbar({ onCreate, totalUsers }: UserToolbarProps) {
  return (
    <header className="users__header">
      <div>
        <h2>Users</h2>
        <p className="users__subtitle">
          Manage the people who can sign in and collaborate. {totalUsers} user
          {totalUsers === 1 ? '' : 's'} registered.
        </p>
      </div>
      <button type="button" className="users__create-button" onClick={onCreate}>
        Invite user
      </button>
    </header>
  )
}

