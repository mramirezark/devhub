import { useTheme } from '../../theme'

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme()
  const label = theme === 'light' ? 'Switch to dark mode' : 'Switch to light mode'

  return (
    <button
      type="button"
      className="theme-toggle"
      onClick={toggleTheme}
      aria-label={label}
      title={label}
    >
      {theme === 'light' ? '🌞' : '🌜'}
    </button>
  )
}

