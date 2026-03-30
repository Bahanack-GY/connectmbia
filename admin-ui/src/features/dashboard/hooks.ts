import { useQuery } from '@tanstack/react-query'
import { dashboardApi } from './api'

export const DASHBOARD_KEYS = {
  stats: ['dashboard', 'stats'] as const,
  recentConsultations: ['dashboard', 'recentConsultations'] as const,
  upcomingAppointments: ['dashboard', 'upcomingAppointments'] as const,
}

export function useAdminStats() {
  return useQuery({
    queryKey: DASHBOARD_KEYS.stats,
    queryFn: dashboardApi.stats,
    staleTime: 30 * 1000,
    refetchInterval: 60 * 1000,
  })
}

export function useRecentConsultations() {
  return useQuery({
    queryKey: DASHBOARD_KEYS.recentConsultations,
    queryFn: dashboardApi.recentConsultations,
    staleTime: 30 * 1000,
  })
}

export function useUpcomingAppointments() {
  return useQuery({
    queryKey: DASHBOARD_KEYS.upcomingAppointments,
    queryFn: dashboardApi.upcomingAppointments,
    staleTime: 30 * 1000,
  })
}
