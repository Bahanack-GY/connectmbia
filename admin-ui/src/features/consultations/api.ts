import { api } from '@/lib/api'

export interface Consultation {
  _id: string
  service: string
  subject: string
  status: string
  paymentMethod: string
  adminNotes?: string
  createdAt: string
  kyc?: {
    name: string
    phone: string
    email: string
    city: string
    country: string
  }
  userId?: { _id: string; name: string; email: string; phone?: string } | string
}

export interface UpdateConsultationDto {
  status: string
  adminNotes?: string
}

export const consultationsApi = {
  list: () => api.get<Consultation[]>('/consultations'),
  getById: (id: string) => api.get<Consultation>(`/consultations/${id}`),
  updateStatus: (id: string, dto: UpdateConsultationDto) =>
    api.patch<Consultation>(`/consultations/${id}/status`, dto),
}
