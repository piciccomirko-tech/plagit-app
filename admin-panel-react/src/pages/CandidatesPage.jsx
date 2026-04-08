import { useState, useEffect } from 'react'
import { adminApi } from '../services/adminApi.js'

export default function CandidatesPage() {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    adminApi.get('/admin/candidates')
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <p>Loading...</p>

  return (
    <div>
      <h1 style={{ fontSize: '24px', marginBottom: '24px' }}>Candidates</h1>
      <pre style={{ background: '#f5f5f5', padding: '16px', borderRadius: '8px', fontSize: '13px', overflow: 'auto' }}>
        {JSON.stringify(data, null, 2)}
      </pre>
    </div>
  )
}
