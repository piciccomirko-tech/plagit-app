import { Outlet, NavLink } from 'react-router-dom'

const navItems = [
  { path: '/dashboard', label: 'Dashboard' },
  { path: '/users', label: 'Users' },
  { path: '/businesses', label: 'Businesses' },
  { path: '/candidates', label: 'Candidates' },
  { path: '/jobs', label: 'Jobs' },
  { path: '/applications', label: 'Applications' },
  { path: '/interviews', label: 'Interviews' },
  { path: '/messages', label: 'Messages' },
  { path: '/notifications', label: 'Notifications' },
  { path: '/matches', label: 'Matches' },
  { path: '/subscriptions', label: 'Subscriptions' },
  { path: '/community', label: 'Community' },
  { path: '/featured', label: 'Featured' },
  { path: '/reports', label: 'Reports' },
  { path: '/logs', label: 'Logs' },
  { path: '/settings', label: 'Settings' },
]

export default function AdminLayout() {
  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <aside style={{
        width: '240px',
        background: 'var(--color-sidebar)',
        color: 'var(--color-sidebar-text)',
        padding: '24px 0',
        flexShrink: 0,
      }}>
        <div style={{ padding: '0 20px 24px', fontWeight: 'bold', fontSize: '18px', color: 'var(--color-primary)' }}>
          PLAGIT ADMIN
        </div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
          {navItems.map(({ path, label }) => (
            <NavLink
              key={path}
              to={path}
              style={({ isActive }) => ({
                display: 'block',
                padding: '10px 20px',
                color: isActive ? 'var(--color-sidebar-active)' : 'var(--color-sidebar-text)',
                background: isActive ? 'rgba(212, 175, 55, 0.1)' : 'transparent',
                textDecoration: 'none',
                fontSize: '14px',
              })}
            >
              {label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <main style={{ flex: 1, padding: '24px 32px', overflow: 'auto' }}>
        <Outlet />
      </main>
    </div>
  )
}
