import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { FileText, CalendarDays, Users, MessageSquare } from 'lucide-react'
import { useAdminStats, useRecentConsultations, useUpcomingAppointments } from './hooks'
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Label,
} from 'recharts'

const SERVICE_LABELS: Record<string, string> = {
  foot: 'Football',
  real_estate: 'Immobilier',
  business: 'Business',
  charity: 'Philanthropie',
}

function statusVariant(
  s: string,
): 'default' | 'success' | 'warning' | 'destructive' | 'secondary' {
  switch (s) {
    case 'confirmed':
    case 'completed':
      return 'success'
    case 'pending':
      return 'warning'
    case 'in_progress':
      return 'default'
    case 'rejected':
    case 'cancelled':
      return 'destructive'
    default:
      return 'secondary'
  }
}

const STATUS_LABELS: Record<string, string> = {
  pending: 'En attente',
  in_progress: 'En cours',
  confirmed: 'Confirmé',
  rejected: 'Rejeté',
  completed: 'Terminé',
  cancelled: 'Annulé',
}

function relativeTime(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 60) return `il y a ${m}m`
  const h = Math.floor(m / 60)
  if (h < 24) return `il y a ${h}h`
  return `il y a ${Math.floor(h / 24)}j`
}

const CONSULTATION_COLORS: Record<string, string> = {
  'En attente':  '#F59E0B',
  'En cours':    '#3B82F6',
  'Confirmé':    '#10B981',
  'Rejeté':      '#EF4444',
  'Terminé':     '#001A4D',
}

const APPOINTMENT_COLORS: Record<string, string> = {
  'En attente': '#F59E0B',
  'Confirmé':   '#10B981',
  'Annulé':     '#EF4444',
  'Terminé':    '#001A4D',
}

const SERVICE_COLORS: Record<string, string> = {
  'Football':      '#001A4D',
  'Immobilier':    '#D4AF37',
  'Business':      '#3B82F6',
  'Philanthropie': '#10B981',
}

function ChartTooltipContent({
  active,
  payload,
}: {
  active?: boolean
  payload?: Array<{ name: string; value: number; payload: { fill?: string; color?: string } }>
}) {
  if (!active || !payload?.length) return null
  const { name, value, payload: p } = payload[0]
  const color = p.fill ?? p.color ?? '#001A4D'
  return (
    <div className="rounded-lg border border-border bg-card px-3 py-2 text-sm">
      <span className="font-medium" style={{ color }}>{name}</span>
      <span className="ml-2 font-bold text-foreground">{value}</span>
    </div>
  )
}

function DonutCenter({ cx, cy, total }: { cx: number; cy: number; total: number }) {
  return (
    <>
      <text x={cx} y={cy - 8} textAnchor="middle" className="fill-foreground" style={{ fontSize: 24, fontWeight: 700 }}>
        {total}
      </text>
      <text x={cx} y={cy + 12} textAnchor="middle" className="fill-muted-foreground" style={{ fontSize: 11 }}>
        total
      </text>
    </>
  )
}

function Spinner() {
  return (
    <div className="flex h-full items-center justify-center py-12">
      <div className="h-7 w-7 rounded-full border-2 border-primary border-t-transparent animate-spin" />
    </div>
  )
}

export function DashboardPage() {
  const { data: stats, isLoading: statsLoading } = useAdminStats()
  const { data: consultations = [], isLoading: consLoading } = useRecentConsultations()
  const { data: appointments = [], isLoading: apptLoading } = useUpcomingAppointments()

  const recent = [...consultations]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 5)

  const upcoming = appointments
    .filter((a) => a.status !== 'cancelled' && a.status !== 'completed')
    .slice(0, 5)

  if (statsLoading) return <Spinner />

  const s = stats!

  const topStats = [
    {
      label: 'Consultations',
      value: s.consultations.total,
      icon: FileText,
      sub: `${s.consultations.pending} en attente`,
      color: 'text-primary',
      bg: 'bg-primary/5',
    },
    {
      label: 'Rendez-vous',
      value: s.appointments.total,
      icon: CalendarDays,
      sub: `${s.appointments.pending + s.appointments.confirmed} actifs`,
      color: 'text-emerald-600',
      bg: 'bg-emerald-50',
    },
    {
      label: 'Utilisateurs',
      value: s.users.total,
      icon: Users,
      sub: `${s.users.clients} client${s.users.clients !== 1 ? 's' : ''}`,
      color: 'text-violet-600',
      bg: 'bg-violet-50',
    },
    {
      label: 'Messagerie',
      value: s.conversations.total,
      icon: MessageSquare,
      sub:
        s.conversations.unread > 0
          ? `${s.conversations.unread} non lu${s.conversations.unread > 1 ? 's' : ''}`
          : 'Tout lu',
      color: 'text-amber-600',
      bg: 'bg-amber-50',
    },
  ]

  const consultationPieData = [
    { name: 'En attente', value: s.consultations.pending },
    { name: 'En cours',   value: s.consultations.in_progress },
    { name: 'Confirmé',   value: s.consultations.confirmed },
    { name: 'Rejeté',     value: s.consultations.rejected },
    { name: 'Terminé',    value: s.consultations.completed },
  ].filter((d) => d.value > 0)

  const appointmentPieData = [
    { name: 'En attente', value: s.appointments.pending },
    { name: 'Confirmé',   value: s.appointments.confirmed },
    { name: 'Annulé',     value: s.appointments.cancelled },
    { name: 'Terminé',    value: s.appointments.completed },
  ].filter((d) => d.value > 0)

  const serviceBarData = Object.entries(
    consultations.reduce<Record<string, number>>((acc, c) => {
      const label = SERVICE_LABELS[c.service] ?? c.service
      acc[label] = (acc[label] ?? 0) + 1
      return acc
    }, {}),
  ).map(([name, count]) => ({ name, count, fill: SERVICE_COLORS[name] ?? '#001A4D' }))

  return (
    <div className="p-8 space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Tableau de bord</h1>
        <p className="text-sm text-muted-foreground mt-1">Vue d'ensemble des activités</p>
      </div>

      {/* Top stats */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
        {topStats.map(({ label, value, icon: Icon, sub, color, bg }) => (
          <Card key={label}>
            <CardContent className="p-5">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{label}</p>
                  <p className="text-3xl font-bold text-foreground mt-1">{value}</p>
                  <p className={`text-xs mt-1 font-medium ${color}`}>{sub}</p>
                </div>
                <div className={`rounded-lg p-2.5 ${bg}`}>
                  <Icon className={`h-5 w-5 ${color}`} />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Status charts */}
      <div className="grid lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader className="pb-1">
            <CardTitle className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">
              Consultations par statut
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-0">
            {consultationPieData.length === 0 ? (
              <p className="py-8 text-center text-sm text-muted-foreground">Aucune donnée</p>
            ) : (
              <>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie
                      data={consultationPieData}
                      cx="50%"
                      cy="50%"
                      innerRadius={62}
                      outerRadius={90}
                      paddingAngle={3}
                      dataKey="value"
                    >
                      {consultationPieData.map((entry) => (
                        <Cell key={entry.name} fill={CONSULTATION_COLORS[entry.name] ?? '#94A3B8'} />
                      ))}
                      <Label
                        content={({ viewBox }) => {
                          if (viewBox && 'cx' in viewBox && 'cy' in viewBox) {
                            return (
                              <DonutCenter
                                cx={viewBox.cx as number}
                                cy={viewBox.cy as number}
                                total={s.consultations.total}
                              />
                            )
                          }
                        }}
                      />
                    </Pie>
                    <Tooltip content={<ChartTooltipContent />} />
                  </PieChart>
                </ResponsiveContainer>
                <div className="flex flex-wrap justify-center gap-x-4 gap-y-1.5 mt-1">
                  {consultationPieData.map((entry) => (
                    <div key={entry.name} className="flex items-center gap-1.5">
                      <span
                        className="h-2.5 w-2.5 rounded-full shrink-0"
                        style={{ background: CONSULTATION_COLORS[entry.name] ?? '#94A3B8' }}
                      />
                      <span className="text-xs text-muted-foreground">
                        {entry.name} <span className="font-semibold text-foreground">({entry.value})</span>
                      </span>
                    </div>
                  ))}
                </div>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-1">
            <CardTitle className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">
              Rendez-vous par statut
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-0">
            {appointmentPieData.length === 0 ? (
              <p className="py-8 text-center text-sm text-muted-foreground">Aucune donnée</p>
            ) : (
              <>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie
                      data={appointmentPieData}
                      cx="50%"
                      cy="50%"
                      innerRadius={62}
                      outerRadius={90}
                      paddingAngle={3}
                      dataKey="value"
                    >
                      {appointmentPieData.map((entry) => (
                        <Cell key={entry.name} fill={APPOINTMENT_COLORS[entry.name] ?? '#94A3B8'} />
                      ))}
                      <Label
                        content={({ viewBox }) => {
                          if (viewBox && 'cx' in viewBox && 'cy' in viewBox) {
                            return (
                              <DonutCenter
                                cx={viewBox.cx as number}
                                cy={viewBox.cy as number}
                                total={s.appointments.total}
                              />
                            )
                          }
                        }}
                      />
                    </Pie>
                    <Tooltip content={<ChartTooltipContent />} />
                  </PieChart>
                </ResponsiveContainer>
                <div className="flex flex-wrap justify-center gap-x-4 gap-y-1.5 mt-1">
                  {appointmentPieData.map((entry) => (
                    <div key={entry.name} className="flex items-center gap-1.5">
                      <span
                        className="h-2.5 w-2.5 rounded-full shrink-0"
                        style={{ background: APPOINTMENT_COLORS[entry.name] ?? '#94A3B8' }}
                      />
                      <span className="text-xs text-muted-foreground">
                        {entry.name} <span className="font-semibold text-foreground">({entry.value})</span>
                      </span>
                    </div>
                  ))}
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Consultations by service */}
      {!consLoading && serviceBarData.length > 0 && (
        <Card>
          <CardHeader className="pb-1">
            <CardTitle className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">
              Consultations par service
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-2">
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={serviceBarData} barSize={40} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--border))" />
                <XAxis
                  dataKey="name"
                  tick={{ fontSize: 12, fill: 'hsl(var(--muted-foreground))' }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis
                  allowDecimals={false}
                  tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                  axisLine={false}
                  tickLine={false}
                />
                <Tooltip content={<ChartTooltipContent />} cursor={{ fill: 'hsl(var(--muted))', radius: 4 }} />
                <Bar dataKey="count" name="Consultations" radius={[4, 4, 0, 0]}>
                  {serviceBarData.map((entry) => (
                    <Cell key={entry.name} fill={entry.fill} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      <div className="grid lg:grid-cols-2 gap-6">
        {/* Recent consultations */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle>Consultations récentes</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {consLoading ? (
              <Spinner />
            ) : recent.length === 0 ? (
              <p className="px-6 pb-6 text-sm text-muted-foreground">Aucune consultation</p>
            ) : (
              <div className="divide-y divide-border">
                {recent.map((c) => (
                  <div key={c._id} className="flex items-center gap-3 px-6 py-3">
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-foreground truncate">
                        {c.kyc?.name ?? c.kyc?.email ?? '—'}
                      </p>
                      <p className="text-xs text-muted-foreground truncate">
                        {SERVICE_LABELS[c.service]} · {c.subject.slice(0, 50)}
                      </p>
                    </div>
                    <div className="flex flex-col items-end gap-1 shrink-0">
                      <Badge variant={statusVariant(c.status)}>
                        {STATUS_LABELS[c.status] ?? c.status}
                      </Badge>
                      <span className="text-[10px] text-muted-foreground">
                        {relativeTime(c.createdAt)}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Upcoming appointments */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle>Prochains rendez-vous</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {apptLoading ? (
              <Spinner />
            ) : upcoming.length === 0 ? (
              <p className="px-6 pb-6 text-sm text-muted-foreground">
                Aucun rendez-vous à venir
              </p>
            ) : (
              <div className="divide-y divide-border">
                {upcoming.map((a) => (
                  <div key={a._id} className="flex items-center gap-3 px-6 py-3">
                    <div className="flex h-9 w-9 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/5 text-primary">
                      <span className="text-xs font-bold leading-none">
                        {new Date(a.date).getDate()}
                      </span>
                      <span className="text-[9px] uppercase">
                        {new Date(a.date).toLocaleString('fr', { month: 'short' })}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-foreground truncate">
                        {a.serviceName}
                      </p>
                      <p className="text-xs text-muted-foreground">{a.time}</p>
                    </div>
                    <Badge variant={statusVariant(a.status)}>
                      {STATUS_LABELS[a.status] ?? a.status}
                    </Badge>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
