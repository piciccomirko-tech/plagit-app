import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { adminApi } from '../services/adminApi.js'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const data = await adminApi.post('/auth/login', { email, password, role: 'admin' })
      localStorage.setItem('plagit_admin_token', data.token)
      navigate('/dashboard')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', background: 'var(--color-bg)' }}>
      <form onSubmit={handleSubmit} style={{ background: 'var(--color-surface)', padding: '40px', borderRadius: '12px', width: '360px', boxShadow: '0 2px 8px rgba(0,0,0,0.08)' }}>
        <h1 style={{ fontSize: '24px', marginBottom: '8px', color: 'var(--color-primary)' }}>Plagit Admin</h1>
        <p style={{ color: 'var(--color-text-muted)', marginBottom: '24px', fontSize: '14px' }}>Sign in to the admin panel</p>
        {error && <p style={{ color: 'var(--color-error)', marginBottom: '12px', fontSize: '14px' }}>{error}</p>}
        <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required style={{ width: '100%', padding: '10px 12px', marginBottom: '12px', border: '1px solid var(--color-border)', borderRadius: '6px', fontSize: '14px' }} />
        <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required style={{ width: '100%', padding: '10px 12px', marginBottom: '20px', border: '1px solid var(--color-border)', borderRadius: '6px', fontSize: '14px' }} />
        <button type="submit" disabled={loading} style={{ width: '100%', padding: '10px', background: 'var(--color-primary)', color: '#fff', border: 'none', borderRadius: '6px', fontSize: '14px', fontWeight: '600', cursor: 'pointer' }}>
          {loading ? 'Signing in...' : 'Sign In'}
        </button>
      </form>
    </div>
  )
}
