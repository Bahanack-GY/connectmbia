/**
 * Central configuration — all API and socket URLs come from here.
 * Override at runtime via Vite env variables:
 *   VITE_API_URL  → overrides API_BASE_URL
 *   VITE_SOCKET_URL → overrides SOCKET_URL
 */
export const API_BASE_URL =
  (import.meta.env.VITE_API_URL as string | undefined) ?? 'http://localhost:3000/api'

export const SOCKET_URL =
  (import.meta.env.VITE_SOCKET_URL as string | undefined) ?? 'http://localhost:3000'
