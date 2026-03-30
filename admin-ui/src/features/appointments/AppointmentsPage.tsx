import { useState } from 'react'
import { useAppointments, useUpdateAppointment } from './hooks'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Search, ChevronRight, User, Phone, Mail } from 'lucide-react'
import type { Appointment } from './api'

function getUser(a: Appointment): { name: string; email: string; phone?: string } | null {
  if (typeof a.userId === 'object' && a.userId)
    return { name: a.userId.name, email: a.userId.email, phone: a.userId.phone }
  return null
}

const STATUS_FILTERS = [
  { value: 'all', label: 'Tous' },
  { value: 'pending', label: 'En attente' },
  { value: 'confirmed', label: 'Confirmé' },
  { value: 'cancelled', label: 'Annulé' },
  { value: 'completed', label: 'Terminé' },
]

const STATUS_LABELS: Record<string, string> = {
  pending: 'En attente',
  confirmed: 'Confirmé',
  cancelled: 'Annulé',
  completed: 'Terminé',
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
    case 'cancelled':
      return 'destructive'
    default:
      return 'secondary'
  }
}

export function AppointmentsPage() {
  const { data: items = [], isLoading } = useAppointments()
  const updateMutation = useUpdateAppointment()

  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [selected, setSelected] = useState<Appointment | null>(null)
  const [editStatus, setEditStatus] = useState('')
  const [editNotes, setEditNotes] = useState('')

  const filtered = items.filter((a) => {
    const matchStatus = filterStatus === 'all' || a.status === filterStatus
    const q = search.toLowerCase()
    const user = getUser(a)
    return (
      matchStatus &&
      (!q ||
        a.serviceName.toLowerCase().includes(q) ||
        user?.name.toLowerCase().includes(q) ||
        user?.email.toLowerCase().includes(q))
    )
  })

  const openDetail = (a: Appointment) => {
    setSelected(a)
    setEditStatus(a.status)
    setEditNotes(a.notes ?? '')
  }

  const handleUpdate = async () => {
    if (!selected) return
    await updateMutation.mutateAsync({
      id: selected._id,
      dto: { status: editStatus, notes: editNotes || undefined },
    })
    setSelected(null)
  }

  return (
    <div className="p-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Rendez-vous</h1>
        <p className="text-sm text-muted-foreground mt-1">
          {items.length} rendez-vous au total
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[200px] max-w-xs">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Rechercher..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>
        <div className="flex gap-1.5 flex-wrap">
          {STATUS_FILTERS.map(({ value, label }) => (
            <button
              key={value}
              onClick={() => setFilterStatus(value)}
              className={`text-xs px-3 py-1.5 rounded-md font-medium transition-colors cursor-pointer ${
                filterStatus === value
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-card border border-border text-muted-foreground hover:text-foreground hover:bg-muted'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      <Card>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex justify-center py-12">
              <div className="h-7 w-7 rounded-full border-2 border-primary border-t-transparent animate-spin" />
            </div>
          ) : filtered.length === 0 ? (
            <p className="py-12 text-center text-sm text-muted-foreground">Aucun résultat</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Client</TableHead>
                  <TableHead>Service</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Heure</TableHead>
                  <TableHead>Statut</TableHead>
                  <TableHead className="w-10" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((a) => {
                  const user = getUser(a)
                  return (
                  <TableRow key={a._id} className="cursor-pointer" onClick={() => openDetail(a)}>
                    <TableCell>
                      {user ? (
                        <div>
                          <p className="font-medium text-sm">{user.name}</p>
                          <p className="text-xs text-muted-foreground">{user.email}</p>
                        </div>
                      ) : (
                        <div className="flex items-center gap-1.5 text-muted-foreground">
                          <User className="h-3.5 w-3.5" />
                          <span className="text-xs">—</span>
                        </div>
                      )}
                    </TableCell>
                    <TableCell>
                      <p className="font-medium text-sm">{a.serviceName}</p>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">
                        {new Date(a.date).toLocaleDateString('fr', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })}
                      </span>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">{a.time}</span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusVariant(a.status)}>
                        {STATUS_LABELS[a.status] ?? a.status}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <ChevronRight className="h-4 w-4 text-muted-foreground" />
                    </TableCell>
                  </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Detail dialog */}
      <Dialog open={!!selected} onOpenChange={(o) => !o && setSelected(null)}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Gérer le rendez-vous</DialogTitle>
          </DialogHeader>

          {selected && (
            <div className="space-y-4">
              {(() => {
                const u = getUser(selected)
                if (!u) return null
                return (
                  <div className="rounded-lg border border-border p-4 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/8 text-primary">
                        <User className="h-4.5 w-4.5" />
                      </div>
                      <p className="text-sm font-semibold text-foreground">{u.name}</p>
                    </div>
                    <div className="space-y-1.5">
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Mail className="h-3.5 w-3.5 shrink-0" />
                        <span className="truncate">{u.email}</span>
                      </div>
                      {u.phone && (
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <Phone className="h-3.5 w-3.5 shrink-0" />
                          <span>{u.phone}</span>
                        </div>
                      )}
                    </div>
                  </div>
                )
              })()}
              <div className="rounded-lg bg-muted/50 p-4 text-sm space-y-1">
                <p className="font-semibold">{selected.serviceName}</p>
                <p className="text-muted-foreground">
                  {new Date(selected.date).toLocaleDateString('fr', {
                    weekday: 'long',
                    day: 'numeric',
                    month: 'long',
                    year: 'numeric',
                  })}{' '}
                  à {selected.time}
                </p>
              </div>

              <div className="space-y-1.5">
                <Label>Statut</Label>
                <Select value={editStatus} onValueChange={setEditStatus}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="pending">En attente</SelectItem>
                    <SelectItem value="confirmed">Confirmé</SelectItem>
                    <SelectItem value="cancelled">Annulé</SelectItem>
                    <SelectItem value="completed">Terminé</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-1.5">
                <Label>Notes</Label>
                <Textarea
                  placeholder="Informations complémentaires..."
                  value={editNotes}
                  onChange={(e) => setEditNotes(e.target.value)}
                  rows={3}
                />
              </div>

              <div className="flex gap-2 justify-end pt-1">
                <Button variant="outline" onClick={() => setSelected(null)}>
                  Annuler
                </Button>
                <Button onClick={handleUpdate} disabled={updateMutation.isPending}>
                  {updateMutation.isPending ? 'Enregistrement...' : 'Enregistrer'}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
