import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

export function useAdminAuth() {
  const [admin, setAdmin] = useState(null)
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    const token = localStorage.getItem('plagit_admin_token')
    if (!token) {
      setLoading(false)
      navigate('/login')
      return
    }
    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      if (payload.role !== 'admin') throw new Error('Not admin')
      setAdmin(payload)
    } catch {
      localStorage.removeItem('plagit_admin_token')
      navigate('/login')
    }
    setLoading(false)
  }, [navigate])

  const logout = () => {
    localStorage.removeItem('plagit_admin_token')
    setAdmin(null)
    navigate('/login')
  }

  return { admin, loading, logout }
}
