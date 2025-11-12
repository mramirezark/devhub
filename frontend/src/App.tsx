import { useEffect, useMemo, useState } from 'react'
import './App.css'
import { TaskDashboard } from './features/tasks/components/TaskDashboard'
import { AuthPanel } from './features/auth/components/AuthPanel'
import { ProjectsPanel } from './features/projects/components/ProjectsPanel'
import { UsersPanel } from './features/users/components/UsersPanel'
import { ThemeToggle } from './features/theme'
import { useAppDispatch, useAppSelector } from './app/hooks'
import { initializeAuth, logout } from './features/auth/authSlice'

type PrimaryTab = 'tasks' | 'projects' | 'users'

function App() {
  const dispatch = useAppDispatch()
  const auth = useAppSelector((state) => state.auth)
  const [activeTab, setActiveTab] = useState<PrimaryTab>('tasks')

  useEffect(() => {
    dispatch(initializeAuth())
  }, [dispatch])

  const isAuthenticated = auth.status === 'authenticated'
  const isAuthenticating = auth.status === 'authenticating' || auth.loading

  useEffect(() => {
    if (!isAuthenticated) {
      setActiveTab('tasks')
    }
  }, [isAuthenticated])

  const mainContent = useMemo(() => {
    if (activeTab === 'projects') {
      return <ProjectsPanel />
    }

    if (activeTab === 'users') {
      return <UsersPanel />
    }

    return <TaskDashboard />
  }, [activeTab])

  const navItems: Array<{
    id: PrimaryTab | 'reports' | 'billing' | 'notifications' | 'support'
    label: string
    icon: string
    disabled?: boolean
  }> = [
    { id: 'tasks', label: 'Tasks', icon: '📊' },
    { id: 'projects', label: 'Projects', icon: '🗂️' },
    { id: 'users', label: 'Users', icon: '👥' },
    { id: 'reports', label: 'Reports', icon: '📈', disabled: true },
    { id: 'billing', label: 'Billing', icon: '💳', disabled: true },
    { id: 'notifications', label: 'Notifications', icon: '🔔', disabled: true },
    { id: 'support', label: 'Support', icon: '💬', disabled: true },
  ]

  const secondaryItems = [
    { label: 'Profile', icon: '🙍‍♂️', disabled: true },
    { label: 'Sign In', icon: '🔐', disabled: !isAuthenticated },
    { label: 'Sign Up', icon: '📝', disabled: true },
  ]

  const displayName = auth.currentUser?.name ?? 'Guest'

  if (!isAuthenticated) {
    return (
      <div className="auth-gate">
        <AuthPanel />
      </div>
    )
  }

  return (
    <div className="dashboard-shell">
      <aside className="sidebar" aria-label="Sidebar navigation">
        <div className="sidebar__brand">
          <span className="sidebar__logo">⌘</span>
          <div className="sidebar__identity">
            <span className="sidebar__title">DevHub</span>
            <span className="sidebar__subtitle">Workspace</span>
          </div>
        </div>

        <nav className="sidebar__nav">
          {navItems.map((item) => {
            const isActive =
              !item.disabled && (item.id === activeTab || (item.id === 'tasks' && activeTab === 'tasks'))
            const isDisabled = item.disabled

            return (
              <button
                key={item.id}
                type="button"
                className={`sidebar__item ${
                  isActive ? 'sidebar__item--active' : ''
                } ${isDisabled ? 'sidebar__item--disabled' : ''}`}
                onClick={() => {
                  if (isDisabled) return
                  if (item.id === 'tasks' || item.id === 'projects' || item.id === 'users') {
                    setActiveTab(item.id)
                  }
                }}
                disabled={isDisabled}
              >
                <span className="sidebar__icon" aria-hidden="true">
                  {item.icon}
                </span>
                <span className="sidebar__label">{item.label}</span>
              </button>
            )
          })}
        </nav>

        <div className="sidebar__section">
          {secondaryItems.map((item) => (
            <button
              key={item.label}
              type="button"
              className={`sidebar__item sidebar__item--muted ${
                item.disabled ? 'sidebar__item--disabled' : ''
              }`}
              disabled={item.disabled}
            >
              <span className="sidebar__icon" aria-hidden="true">
                {item.icon}
              </span>
              <span className="sidebar__label">{item.label}</span>
            </button>
          ))}
        </div>
      </aside>

      <div className="workspace">
        <header className="topbar">
          <div className="topbar__breadcrumbs">
            <span className="topbar__crumb">Dashboard</span>
            <span className="topbar__crumb-divider">/</span>
            <span className="topbar__crumb topbar__crumb--active">
              {activeTab === 'tasks' ? 'Overview' : activeTab === 'projects' ? 'Projects' : 'Users'}
            </span>
          </div>

          <div className="topbar__actions">
            <label className="topbar__search">
              <span className="topbar__search-icon" aria-hidden="true">
                🔍
              </span>
              <input type="search" placeholder="Search" />
            </label>
            <button type="button" className="topbar__icon-button" aria-label="Notifications">
              🔔
            </button>
            <button type="button" className="topbar__icon-button" aria-label="Settings">
              ⚙️
            </button>
            <ThemeToggle />
            <div className="topbar__profile">
              <div className="topbar__avatar" aria-hidden="true">
                {displayName.charAt(0).toUpperCase()}
              </div>
              <div>
                <p className="topbar__profile-name">{displayName}</p>
                <p className="topbar__profile-role">
                  {auth.currentUser?.admin ? 'Administrator' : 'Collaborator'}
                </p>
              </div>
              {isAuthenticated ? (
                <button
                  type="button"
                  className="topbar__logout"
                  onClick={() => dispatch(logout())}
                  disabled={isAuthenticating}
                >
                  Log out
                </button>
              ) : null}
            </div>
          </div>
        </header>

        <main className="workspace__content">{mainContent}</main>
      </div>
    </div>
  )
}

export default App
