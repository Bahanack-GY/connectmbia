import { api } from '@/lib/api'

export interface AdminStats {
  users: { total: number; clients: number; admins: number }
  consultations: {
    total: number
    pending: number
    in_progress: number
    confirmed: number
    rejected: number
    completed: number
  }
  appointments: {
    total: number
    pending: number
    confirmed: number
    cancelled: number
    completed: number
  }
  conversations: { total: number; unread: number }
}

export interface RecentConsultation {
  _id: string
  service: string
  subject: string
  status: string
  createdAt: string
  kyc?: { name: string; email: string }
}

export interface UpcomingAppointment {
  _id: string
  serviceName: string
  date: string
  time: string
  status: string
}

export const dashboardApi = {
  stats: () => api.get<AdminStats>('/admin/stats'),
  recentConsultations: () => api.get<RecentConsultation[]>('/consultations'),
  upcomingAppointments: () => api.get<UpcomingAppointment[]>('/appointments'),
}
