import { useState, useEffect } from 'react'
import { adminApi } from '../services/adminApi.js'

export default function DashboardPage() {
  const [stats, setStats] = useState(null)

  useEffect(() => {
    adminApi.get('/admin/dashboard/stats').then(setStats).catch(console.error)
  }, [])

  return (
    <div>
      <h1 style={{ fontSize: '24px', marginBottom: '24px' }}>Dashboard</h1>
      {stats ? (
        <pre style={{ background: '#f5f5f5', padding: '16px', borderRadius: '8px', fontSize: '13px' }}>
          {JSON.stringify(stats, null, 2)}
        </pre>
      ) : (
        <p>Loading stats...</p>
      )}
    </div>
  )
}
