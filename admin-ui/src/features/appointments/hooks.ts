import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { appointmentsApi, type UpdateAppointmentDto, type CreateAppointmentForUserDto } from './api'
import { DASHBOARD_KEYS } from '@/features/dashboard/hooks'

export const APPOINTMENT_KEYS = {
  all: ['appointments'] as const,
  detail: (id: string) => ['appointments', id] as const,
}

export function useAppointments() {
  return useQuery({
    queryKey: APPOINTMENT_KEYS.all,
    queryFn: appointmentsApi.list,
    staleTime: 30 * 1000,
  })
}

export function useUpdateAppointment() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, dto }: { id: string; dto: UpdateAppointmentDto }) =>
      appointmentsApi.updateStatus(id, dto),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: APPOINTMENT_KEYS.all })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.stats })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.upcomingAppointments })
    },
  })
}

export function useCreateAppointmentForUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (dto: CreateAppointmentForUserDto) => appointmentsApi.createForUser(dto),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: APPOINTMENT_KEYS.all })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.stats })
    },
  })
}
