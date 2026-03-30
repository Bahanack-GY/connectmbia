import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { usersApi } from './api'
import { DASHBOARD_KEYS } from '@/features/dashboard/hooks'

export const USER_KEYS = {
  all: ['users'] as const,
  detail: (id: string) => ['users', id] as const,
}

export function useUsers() {
  return useQuery({
    queryKey: USER_KEYS.all,
    queryFn: usersApi.list,
    staleTime: 60 * 1000,
  })
}

export function useUpdateUserRole() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, role }: { id: string; role: string }) =>
      usersApi.updateRole(id, role),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: USER_KEYS.all })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.stats })
    },
  })
}

export function useDeleteUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => usersApi.deleteUser(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: USER_KEYS.all })
      qc.invalidateQueries({ queryKey: DASHBOARD_KEYS.stats })
    },
  })
}
