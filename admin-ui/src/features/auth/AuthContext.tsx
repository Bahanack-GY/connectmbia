import React, { createContext, useContext, useState, useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { authApi, type AdminUser } from './api'

interface AuthContextValue {
  user: AdminUser | null
  loading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const queryClient = useQueryClient()
  const [user, setUser] = useState<AdminUser | null>(null)
  const [loading, setLoading] = useState(true)

  // Verify stored token on mount
  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (!token) {
      setLoading(false)
      return
    }
    authApi
      .profile()
      .then((u) => {
        if (u.role !== 'admin') {
          localStorage.removeItem('admin_token')
          setUser(null)
        } else {
          setUser(u)
        }
      })
      .catch(() => {
        localStorage.removeItem('admin_token')
        setUser(null)
      })
      .finally(() => setLoading(false))
  }, [])

  const login = async (email: string, password: string) => {
    const res = await authApi.login(email, password)
    if (res.user.role !== 'admin') {
      throw new Error('Accès refusé — compte non administrateur')
    }
    // Accept both key formats from the server
    const token = res.access_token ?? res.accessToken
    localStorage.setItem('admin_token', token)
    setUser(res.user)
  }

  const logout = () => {
    localStorage.removeItem('admin_token')
    setUser(null)
    queryClient.clear()
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
