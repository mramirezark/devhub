import { useEffect, useRef } from 'react'
import { createPortal } from 'react-dom'
import type { ReactNode } from 'react'

type ModalProps = {
  open: boolean
  title?: string
  onClose: () => void
  children: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg'
}

const SIZE_CLASS_MAP: Record<NonNullable<ModalProps['size']>, string> = {
  sm: 'modal__dialog--sm',
  md: 'modal__dialog--md',
  lg: 'modal__dialog--lg',
}

export function Modal({
  open,
  title,
  onClose,
  children,
  footer,
  size = 'md',
}: ModalProps) {
  const dialogRef = useRef<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!open) return

    const keyHandler = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        onClose()
      }
    }

    document.addEventListener('keydown', keyHandler)
    const originalOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'

    return () => {
      document.removeEventListener('keydown', keyHandler)
      document.body.style.overflow = originalOverflow
    }
  }, [open, onClose])

  useEffect(() => {
    if (open && dialogRef.current) {
      dialogRef.current.focus({ preventScroll: true })
    }
  }, [open])

  if (!open) {
    return null
  }

  return createPortal(
    <div
      className="modal"
      role="presentation"
      onClick={onClose}
      aria-hidden={!open}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className={`modal__dialog ${SIZE_CLASS_MAP[size]}`}
        onClick={(event) => event.stopPropagation()}
        tabIndex={-1}
        ref={dialogRef}
      >
        <header className="modal__header">
          {title ? <h2>{title}</h2> : null}
          <button
            type="button"
            className="modal__close"
            onClick={onClose}
            aria-label="Close dialog"
          >
            ×
          </button>
        </header>

        <div className="modal__body">{children}</div>

        {footer ? <footer className="modal__footer">{footer}</footer> : null}
      </div>
    </div>,
    document.body,
  )
}

