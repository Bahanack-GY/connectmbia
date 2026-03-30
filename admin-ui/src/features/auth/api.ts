import { api } from '@/lib/api'

export interface AdminUser {
  id: string
  name: string
  email: string
  role: string
  phone?: string
  avatar?: string
}

export interface LoginResponse {
  access_token: string
  accessToken: string
  user: AdminUser
}

export const authApi = {
  login: (email: string, password: string) =>
    api.post<LoginResponse>('/auth/login', { email, password }),

  profile: () => api.get<AdminUser>('/auth/profile'),
}
