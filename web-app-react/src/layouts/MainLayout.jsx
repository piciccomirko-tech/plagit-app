import { Outlet, Link } from 'react-router-dom'

export default function MainLayout() {
  return (
    <div className="min-h-screen">
      <header style={{ padding: '16px 32px', borderBottom: '1px solid #eee', display: 'flex', alignItems: 'center', gap: '24px' }}>
        <Link to="/" style={{ fontWeight: 'bold', fontSize: '20px', color: '#D4AF37', textDecoration: 'none' }}>
          PLAGIT
        </Link>
        <nav style={{ display: 'flex', gap: '16px' }}>
          <Link to="/jobs">Jobs</Link>
          <Link to="/login">Sign In</Link>
        </nav>
      </header>
      <main style={{ padding: '32px' }}>
        <Outlet />
      </main>
    </div>
  )
}
