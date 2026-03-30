import { api } from '@/lib/api'

export interface Appointment {
  _id: string
  serviceName: string
  date: string
  time: string
  status: string
  meetLink?: string
  notes?: string
  userId?: { _id: string; name: string; email: string; phone?: string } | string
  createdAt?: string
}

export interface UpdateAppointmentDto {
  status: string
  meetLink?: string
  notes?: string
}

export interface CreateAppointmentForUserDto {
  userId: string
  conversationId?: string
  serviceName: string
  date: string
  time: string
  meetLink?: string
  notes?: string
}

export const appointmentsApi = {
  list: () => api.get<Appointment[]>('/appointments'),
  getById: (id: string) => api.get<Appointment>(`/appointments/${id}`),
  updateStatus: (id: string, dto: UpdateAppointmentDto) =>
    api.patch<Appointment>(`/appointments/${id}/status`, dto),
  createForUser: (dto: CreateAppointmentForUserDto) =>
    api.post<Appointment>('/admin/appointments', dto),
}
