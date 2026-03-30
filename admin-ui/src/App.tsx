import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from '@/features/auth/AuthContext'
import { AppLayout } from '@/components/layout/AppLayout'
import { LoginPage } from '@/features/auth/LoginPage'
import { DashboardPage } from '@/features/dashboard/DashboardPage'
import { ConsultationsPage } from '@/features/consultations/ConsultationsPage'
import { AppointmentsPage } from '@/features/appointments/AppointmentsPage'
import { UsersPage } from '@/features/users/UsersPage'
import { ChatPage } from '@/features/chat/ChatPage'

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route element={<AppLayout />}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/consultations" element={<ConsultationsPage />} />
            <Route path="/appointments" element={<AppointmentsPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/chat" element={<ChatPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
