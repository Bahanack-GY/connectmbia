import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { consultationsApi, type UpdateConsultationDto } from './api'
import { DASHBOARD_KEYS } from '@/features/dashboard/hooks'

export const CONSULTATION_KEYS = {
  all: ['consultations'] as const,
  detail: (id: string) => ['consultations', id] as const,
}

export function useConsultations() {
  return useQuery({
    queryKey: CONSULTATION_KEYS.all,
    queryFn: consultationsApi.list,
    staleTime: 30 * 1000,
  })
}

export function useUpdateConsultation() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, dto }: { id: string; dto: UpdateConsultationDto }) =>
      consultationsApi.updateStatus(id, dto),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: CONSULTATION_KEYS.all })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.stats })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.recentConsultations })
    },
  })
}
