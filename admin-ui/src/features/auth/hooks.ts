import { useQuery } from '@tanstack/react-query'
import { authApi } from './api'

export const AUTH_KEYS = {
  profile: ['auth', 'profile'] as const,
}

export function useProfile(enabled: boolean) {
  return useQuery({
    queryKey: AUTH_KEYS.profile,
    queryFn: authApi.profile,
    enabled,
    retry: false,
    staleTime: 5 * 60 * 1000,
  })
}
