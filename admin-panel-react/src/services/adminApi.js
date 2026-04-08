const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000/v1'

async function request(path, options = {}) {
  const token = localStorage.getItem('plagit_admin_token')
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  })
  const data = await res.json()
  if (!res.ok) {
    if (res.status === 401) {
      localStorage.removeItem('plagit_admin_token')
      window.location.href = '/login'
    }
    throw new Error(data.error || 'Request failed')
  }
  return data
}

export const adminApi = {
  get: (path) => request(path),
  post: (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) }),
  put: (path, body) => request(path, { method: 'PUT', body: JSON.stringify(body) }),
  delete: (path) => request(path, { method: 'DELETE' }),
}
