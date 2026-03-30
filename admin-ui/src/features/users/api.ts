import { api } from '@/lib/api'

export interface User {
  _id: string
  name: string
  email: string
  phone?: string
  role: string
  avatar?: string
  createdAt?: string
}

export const usersApi = {
  list: () => api.get<User[]>('/users'),
  getById: (id: string) => api.get<User>(`/users/${id}`),
  updateRole: (id: string, role: string) =>
    api.patch<User>(`/users/${id}/role`, { role }),
  deleteUser: (id: string) => api.delete<void>(`/users/${id}`),
}
