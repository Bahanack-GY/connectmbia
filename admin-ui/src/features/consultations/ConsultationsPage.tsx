import { useState } from 'react'
import { type Consultation } from './api'
import { useConsultations, useUpdateConsultation } from './hooks'
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
import { Search, SlidersHorizontal, ChevronRight } from 'lucide-react'

const SERVICE_LABELS: Record<string, string> = {
  foot: 'Football',
  real_estate: 'Immobilier',
  business: 'Business',
  charity: 'Philanthropie',
}

const PAYMENT_LABELS: Record<string, string> = {
  om: 'Orange Money',
  momo: 'MTN MoMo',
  card: 'Carte',
}

const STATUS_FILTERS = [
  { value: 'all', label: 'Tous' },
  { value: 'pending', label: 'En attente' },
  { value: 'in_progress', label: 'En cours' },
  { value: 'confirmed', label: 'Confirmé' },
  { value: 'rejected', label: 'Rejeté' },
  { value: 'completed', label: 'Terminé' },
]

const STATUS_LABELS: Record<string, string> = {
  pending: 'En attente',
  in_progress: 'En cours',
  confirmed: 'Confirmé',
  rejected: 'Rejeté',
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
    case 'in_progress':
      return 'default'
    case 'rejected':
      return 'destructive'
    default:
      return 'secondary'
  }
}

function FilterButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      onClick={onClick}
      className={`text-xs px-3 py-1.5 rounded-md font-medium transition-colors cursor-pointer ${
        active
          ? 'bg-primary text-primary-foreground'
          : 'bg-card border border-border text-muted-foreground hover:text-foreground hover:bg-muted'
      }`}
    >
      {children}
    </button>
  )
}

export function ConsultationsPage() {
  const { data: items = [], isLoading } = useConsultations()
  const updateMutation = useUpdateConsultation()

  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [selected, setSelected] = useState<Consultation | null>(null)
  const [editStatus, setEditStatus] = useState('')
  const [editNotes, setEditNotes] = useState('')

  const filtered = items.filter((c) => {
    const matchStatus = filterStatus === 'all' || c.status === filterStatus
    const q = search.toLowerCase()
    return (
      matchStatus &&
      (!q ||
        c.kyc?.name.toLowerCase().includes(q) ||
        c.kyc?.email.toLowerCase().includes(q) ||
        c.subject.toLowerCase().includes(q) ||
        SERVICE_LABELS[c.service]?.toLowerCase().includes(q))
    )
  })

  const openDetail = (c: Consultation) => {
    setSelected(c)
    setEditStatus(c.status)
    setEditNotes(c.adminNotes ?? '')
  }

  const handleUpdate = async () => {
    if (!selected) return
    await updateMutation.mutateAsync({ id: selected._id, dto: { status: editStatus, adminNotes: editNotes } })
    setSelected(null)
  }

  return (
    <div className="p-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Consultations</h1>
        <p className="text-sm text-muted-foreground mt-1">
          {items.length} consultation{items.length !== 1 ? 's' : ''} au total
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
        <div className="flex items-center gap-2">
          <SlidersHorizontal className="h-4 w-4 text-muted-foreground" />
          <div className="flex gap-1.5 flex-wrap">
            {STATUS_FILTERS.map(({ value, label }) => (
              <FilterButton
                key={value}
                active={filterStatus === value}
                onClick={() => setFilterStatus(value)}
              >
                {label}
              </FilterButton>
            ))}
          </div>
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
                  <TableHead>Sujet</TableHead>
                  <TableHead>Paiement</TableHead>
                  <TableHead>Statut</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead className="w-10" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((c) => (
                  <TableRow key={c._id} className="cursor-pointer" onClick={() => openDetail(c)}>
                    <TableCell>
                      <div>
                        <p className="font-medium text-sm">{c.kyc?.name ?? '—'}</p>
                        <p className="text-xs text-muted-foreground">{c.kyc?.email}</p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">{SERVICE_LABELS[c.service] ?? c.service}</span>
                    </TableCell>
                    <TableCell>
                      <p className="text-sm text-muted-foreground max-w-[200px] truncate">
                        {c.subject}
                      </p>
                    </TableCell>
                    <TableCell>
                      <span className="text-xs text-muted-foreground">
                        {PAYMENT_LABELS[c.paymentMethod] ?? c.paymentMethod ?? '—'}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusVariant(c.status)}>
                        {STATUS_LABELS[c.status] ?? c.status}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <span className="text-xs text-muted-foreground">
                        {new Date(c.createdAt).toLocaleDateString('fr')}
                      </span>
                    </TableCell>
                    <TableCell>
                      <ChevronRight className="h-4 w-4 text-muted-foreground" />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Detail dialog */}
      <Dialog open={!!selected} onOpenChange={(o) => !o && setSelected(null)}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Détail de la consultation</DialogTitle>
          </DialogHeader>

          {selected && (
            <div className="space-y-5">
              <div className="rounded-lg bg-muted/50 p-4 text-sm space-y-2">
                <div className="grid grid-cols-2 gap-x-4 gap-y-1">
                  {[
                    ['Nom', selected.kyc?.name],
                    ['Email', selected.kyc?.email],
                    ['Téléphone', selected.kyc?.phone],
                    [
                      'Localisation',
                      [selected.kyc?.city, selected.kyc?.country].filter(Boolean).join(', ') ||
                        undefined,
                    ],
                  ].map(([label, value]) => (
                    <div key={label}>
                      <p className="text-xs text-muted-foreground">{label}</p>
                      <p className="font-medium">{value ?? '—'}</p>
                    </div>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex gap-2 flex-wrap">
                  <Badge variant="secondary">
                    {SERVICE_LABELS[selected.service] ?? selected.service}
                  </Badge>
                  <Badge variant="secondary">
                    {PAYMENT_LABELS[selected.paymentMethod] ?? selected.paymentMethod}
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground">{selected.subject}</p>
              </div>

              <div className="space-y-1.5">
                <Label>Statut</Label>
                <Select value={editStatus} onValueChange={setEditStatus}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="pending">En attente</SelectItem>
                    <SelectItem value="in_progress">En cours</SelectItem>
                    <SelectItem value="confirmed">Confirmé</SelectItem>
                    <SelectItem value="rejected">Rejeté</SelectItem>
                    <SelectItem value="completed">Terminé</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-1.5">
                <Label>Notes administrateur</Label>
                <Textarea
                  placeholder="Remarques internes..."
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
