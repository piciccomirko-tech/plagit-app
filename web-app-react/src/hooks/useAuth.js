import { useState, useEffect } from 'react'

export function useAuth() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('plagit_token')
    if (token) {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]))
        setUser(payload)
      } catch {
        localStorage.removeItem('plagit_token')
      }
    }
    setLoading(false)
  }, [])

  const logout = () => {
    localStorage.removeItem('plagit_token')
    setUser(null)
  }

  return { user, loading, logout }
}
