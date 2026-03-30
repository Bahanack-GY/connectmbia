import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard,
  FileText,
  CalendarDays,
  Users,
  MessageSquare,
  LogOut,
  ChevronRight,
} from 'lucide-react'
import { useAuth } from '@/features/auth/AuthContext'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { cn } from '@/lib/utils'

const NAV_ITEMS = [
  { to: '/dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
  { to: '/consultations', label: 'Consultations', icon: FileText },
  { to: '/appointments', label: 'Rendez-vous', icon: CalendarDays },
  { to: '/users', label: 'Utilisateurs', icon: Users },
  { to: '/chat', label: 'Messagerie', icon: MessageSquare },
]

export function Sidebar() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const initials = user?.name
    ? user.name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : 'AD'

  return (
    <aside className="fixed inset-y-0 left-0 z-20 flex w-60 flex-col bg-sidebar">
      {/* Logo */}
      <div className="flex h-16 shrink-0 items-center gap-3 border-b border-sidebar-border px-5">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gold/20 border border-gold/30">
          <span className="text-gold text-xs font-bold">MC</span>
        </div>
        <div>
          <p className="text-sm font-bold text-white leading-tight">Mbia Consulting</p>
          <p className="text-[10px] text-sidebar-foreground/60 uppercase tracking-widest">
            Administration
          </p>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-0.5">
        {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              cn(
                'group flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-sidebar-accent text-white'
                  : 'text-sidebar-foreground hover:bg-white/5 hover:text-white',
              )
            }
          >
            {({ isActive }) => (
              <>
                <Icon
                  className={cn(
                    'h-4 w-4 shrink-0 transition-colors',
                    isActive ? 'text-gold' : 'text-sidebar-foreground group-hover:text-white',
                  )}
                />
                <span className="flex-1">{label}</span>
                {isActive && <ChevronRight className="h-3 w-3 text-gold/60" />}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      {/* User + Logout */}
      <div className="shrink-0 border-t border-sidebar-border p-3">
        <div className="flex items-center gap-3 rounded-lg px-2 py-2">
          <Avatar className="h-8 w-8">
            <AvatarFallback className="bg-gold/20 text-gold text-xs">{initials}</AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-white truncate">{user?.name ?? 'Admin'}</p>
            <p className="text-[11px] text-sidebar-foreground/60 truncate">{user?.email}</p>
          </div>
          <button
            onClick={handleLogout}
            className="rounded-md p-1.5 text-sidebar-foreground/60 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
            title="Se déconnecter"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </div>
    </aside>
  )
}
