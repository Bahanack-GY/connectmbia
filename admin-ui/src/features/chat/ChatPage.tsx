import { useEffect, useRef, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { useConversations, useMessages, CHAT_KEYS } from './hooks'
import { createChatSocket, type Conversation, type Message } from './api'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Send, MessageSquare, CalendarPlus } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { Socket } from 'socket.io-client'
import { useCreateAppointmentForUser } from '@/features/appointments/hooks'

const SERVICES = [
  'Consultation juridique',
  'Conseil en investissement',
  'Accompagnement fiscal',
  'Planification successorale',
  'Création d\'entreprise',
  'Audit financier',
  'Autre',
]

function conversationName(conv: Conversation): string {
  if (typeof conv.userId === 'object') {
    return conv.userId?.name ?? conv.userId?.email ?? conv.subject
  }
  return conv.subject || 'Discussion'
}

function conversationEmail(conv: Conversation): string | null {
  if (typeof conv.userId === 'object') return conv.userId?.email ?? null
  return null
}

function timeLabel(dateStr: string) {
  const d = new Date(dateStr)
  const diff = Date.now() - d.getTime()
  if (diff < 86400000) return d.toLocaleTimeString('fr', { hour: '2-digit', minute: '2-digit' })
  if (diff < 7 * 86400000) return d.toLocaleDateString('fr', { weekday: 'short' })
  return d.toLocaleDateString('fr', { day: 'numeric', month: 'short' })
}

function initials(name: string) {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

const EMPTY_FORM = { serviceName: '', date: '', time: '', meetLink: '', notes: '' }

export function ChatPage() {
  const qc = useQueryClient()
  const { data: conversations = [], isLoading: convLoading } = useConversations()
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const { data: messages = [], isLoading: msgLoading } = useMessages(selectedId)
  const [text, setText] = useState('')
  const bottomRef = useRef<HTMLDivElement>(null)
  const socketRef = useRef<Socket | null>(null)
  // Keep a ref to selectedId so socket event handlers always see the current value
  const selectedIdRef = useRef<string | null>(null)

  // Appointment dialog
  const [rdvOpen, setRdvOpen] = useState(false)
  const [rdvForm, setRdvForm] = useState(EMPTY_FORM)
  const createAppointment = useCreateAppointmentForUser()

  useEffect(() => {
    selectedIdRef.current = selectedId
  }, [selectedId])

  // Create socket once for the lifetime of this page
  useEffect(() => {
    const socket = createChatSocket()
    socketRef.current = socket

    socket.on('new_message', (msg: Message) => {
      const convId = selectedIdRef.current
      if (convId) {
        qc.setQueryData<Message[]>(CHAT_KEYS.messages(convId), (prev = []) =>
          prev.some((m) => m._id === msg._id) ? prev : [...prev, msg],
        )
      }
      qc.invalidateQueries({ queryKey: CHAT_KEYS.conversations })
    })

    socket.on('message_history', (history: Message[]) => {
      const convId = selectedIdRef.current
      if (convId) {
        qc.setQueryData<Message[]>(CHAT_KEYS.messages(convId), history)
      }
    })

    socket.on('conversation_updated', () => {
      qc.invalidateQueries({ queryKey: CHAT_KEYS.conversations })
    })

    return () => {
      socket.disconnect()
      socketRef.current = null
    }
  }, [qc]) // runs once — qc is stable

  // Join room whenever the selected conversation changes
  useEffect(() => {
    if (!selectedId) return
    socketRef.current?.emit('join_conversation', selectedId)
    // Clear unread count in the cached list
    qc.setQueryData<Conversation[]>(CHAT_KEYS.conversations, (prev) =>
      prev?.map((c) => (c._id === selectedId ? { ...c, unreadCount: 0 } : c)),
    )
  }, [selectedId, qc])

  // Scroll to bottom when messages update
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const sendMessage = () => {
    if (!text.trim() || !selectedId || !socketRef.current) return
    socketRef.current.emit('send_message', { conversationId: selectedId, text: text.trim() })
    setText('')
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  const selectedConv = conversations.find((c) => c._id === selectedId)
  const sortedConversations = [...conversations].sort(
    (a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime(),
  )

  const handleRdvSubmit = () => {
    if (!selectedConv || !rdvForm.serviceName || !rdvForm.date || !rdvForm.time) return
    const userId =
      typeof selectedConv.userId === 'object' ? selectedConv.userId._id : selectedConv.userId
    createAppointment.mutate(
      {
        userId,
        conversationId: selectedConv._id,
        serviceName: rdvForm.serviceName,
        date: rdvForm.date,
        time: rdvForm.time,
        meetLink: rdvForm.meetLink || undefined,
        notes: rdvForm.notes || undefined,
      },
      {
        onSuccess: () => {
          setRdvOpen(false)
          setRdvForm(EMPTY_FORM)
        },
      },
    )
  }

  return (
    <div className="flex h-screen">
      {/* Conversation list */}
      <div className="w-72 shrink-0 border-r border-border flex flex-col bg-card">
        <div className="p-4 border-b border-border shrink-0">
          <h2 className="font-semibold text-foreground">Messagerie</h2>
          <p className="text-xs text-muted-foreground mt-0.5">
            {conversations.length} conversation{conversations.length !== 1 ? 's' : ''}
          </p>
        </div>

        {/* Plain overflow div — avoids Radix ScrollArea React 19 ref loop */}
        <div className="flex-1 overflow-y-auto min-h-0">
          {convLoading ? (
            <div className="flex justify-center py-8">
              <div className="h-6 w-6 rounded-full border-2 border-primary border-t-transparent animate-spin" />
            </div>
          ) : sortedConversations.length === 0 ? (
            <p className="py-8 text-center text-sm text-muted-foreground">Aucune conversation</p>
          ) : (
            <div className="p-2 space-y-0.5">
              {sortedConversations.map((conv) => {
                const name = conversationName(conv)
                const isActive = conv._id === selectedId
                return (
                  <button
                    key={conv._id}
                    onClick={() => setSelectedId(conv._id)}
                    className={cn(
                      'w-full text-left rounded-lg px-3 py-2.5 transition-colors cursor-pointer',
                      isActive ? 'bg-primary/8 border border-primary/20' : 'hover:bg-muted/60',
                    )}
                  >
                    <div className="flex items-start gap-2.5">
                      <Avatar className="h-8 w-8 shrink-0 mt-0.5">
                        <AvatarFallback className="text-xs">{initials(name)}</AvatarFallback>
                      </Avatar>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-1">
                          <p
                            className={cn(
                              'text-sm truncate',
                              isActive || conv.unreadCount > 0 ? 'font-semibold' : 'font-medium',
                            )}
                          >
                            {name}
                          </p>
                          <span className="text-[10px] text-muted-foreground shrink-0">
                            {timeLabel(conv.updatedAt)}
                          </span>
                        </div>
                        <p className="text-xs text-muted-foreground truncate mt-0.5">
                          {conv.lastMessage || conv.subject}
                        </p>
                      </div>
                      {conv.unreadCount > 0 && (
                        <Badge className="h-4 min-w-4 text-[10px] px-1 flex items-center justify-center shrink-0">
                          {conv.unreadCount}
                        </Badge>
                      )}
                    </div>
                  </button>
                )
              })}
            </div>
          )}
        </div>
      </div>

      {/* Chat area */}
      <div className="flex-1 flex flex-col min-w-0 min-h-0">
        {selectedConv ? (
          <>
            {/* Header */}
            <div className="h-14 shrink-0 border-b border-border px-5 flex items-center gap-3 bg-card">
              <Avatar className="h-8 w-8">
                <AvatarFallback className="text-xs">
                  {initials(conversationName(selectedConv))}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold">{conversationName(selectedConv)}</p>
                {conversationEmail(selectedConv) && (
                  <p className="text-xs text-muted-foreground">
                    {conversationEmail(selectedConv)}
                  </p>
                )}
              </div>
              <Button
                variant="outline"
                size="sm"
                className="shrink-0 gap-1.5"
                onClick={() => setRdvOpen(true)}
              >
                <CalendarPlus className="h-3.5 w-3.5" />
                Planifier RDV
              </Button>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto min-h-0 p-5">
              {msgLoading ? (
                <div className="flex justify-center py-8">
                  <div className="h-6 w-6 rounded-full border-2 border-primary border-t-transparent animate-spin" />
                </div>
              ) : messages.length === 0 ? (
                <p className="text-center text-sm text-muted-foreground py-8">Aucun message</p>
              ) : (
                <div className="space-y-3">
                  {messages.map((msg) => {
                    const isAdmin = msg.senderRole === 'admin'
                    return (
                      <div
                        key={msg._id}
                        className={cn('flex', isAdmin ? 'justify-end' : 'justify-start')}
                      >
                        <div
                          className={cn(
                            'max-w-[70%] rounded-2xl px-4 py-2.5',
                            isAdmin
                              ? 'bg-primary text-primary-foreground rounded-tr-sm'
                              : 'bg-card border border-border text-foreground rounded-tl-sm',
                          )}
                        >
                          <p className="text-sm leading-relaxed">{msg.text}</p>
                          <p
                            className={cn(
                              'text-[10px] mt-1',
                              isAdmin ? 'text-white/60' : 'text-muted-foreground',
                            )}
                          >
                            {new Date(msg.createdAt).toLocaleTimeString('fr', {
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </p>
                        </div>
                      </div>
                    )
                  })}
                  <div ref={bottomRef} />
                </div>
              )}
            </div>

            {/* Input */}
            <div className="shrink-0 border-t border-border p-4 bg-card">
              <div className="flex items-end gap-2">
                <textarea
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder="Écrire un message... (Entrée pour envoyer)"
                  rows={1}
                  className="flex-1 resize-none rounded-lg border border-border bg-background px-3 py-2 text-sm placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring min-h-[38px] max-h-32 font-[inherit]"
                  onInput={(e) => {
                    const t = e.currentTarget
                    t.style.height = 'auto'
                    t.style.height = Math.min(t.scrollHeight, 128) + 'px'
                  }}
                />
                <Button
                  size="icon"
                  onClick={sendMessage}
                  disabled={!text.trim()}
                  className="shrink-0"
                >
                  <Send className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Schedule appointment dialog */}
            <Dialog open={rdvOpen} onOpenChange={setRdvOpen}>
              <DialogContent className="sm:max-w-md">
                <DialogHeader>
                  <DialogTitle>Planifier un rendez-vous</DialogTitle>
                </DialogHeader>
                <div className="grid gap-4 py-2">
                  <div className="grid gap-1.5">
                    <Label>Service</Label>
                    <Select
                      value={rdvForm.serviceName}
                      onValueChange={(v) => setRdvForm((f) => ({ ...f, serviceName: v }))}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Choisir un service" />
                      </SelectTrigger>
                      <SelectContent>
                        {SERVICES.map((s) => (
                          <SelectItem key={s} value={s}>
                            {s}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="grid gap-1.5">
                      <Label>Date</Label>
                      <Input
                        type="date"
                        value={rdvForm.date}
                        onChange={(e) => setRdvForm((f) => ({ ...f, date: e.target.value }))}
                      />
                    </div>
                    <div className="grid gap-1.5">
                      <Label>Heure</Label>
                      <Input
                        type="time"
                        value={rdvForm.time}
                        onChange={(e) => setRdvForm((f) => ({ ...f, time: e.target.value }))}
                      />
                    </div>
                  </div>
                  <div className="grid gap-1.5">
                    <Label>Lien Meet (optionnel)</Label>
                    <Input
                      placeholder="https://meet.google.com/..."
                      value={rdvForm.meetLink}
                      onChange={(e) => setRdvForm((f) => ({ ...f, meetLink: e.target.value }))}
                    />
                  </div>
                  <div className="grid gap-1.5">
                    <Label>Notes (optionnel)</Label>
                    <Input
                      placeholder="Informations complémentaires"
                      value={rdvForm.notes}
                      onChange={(e) => setRdvForm((f) => ({ ...f, notes: e.target.value }))}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setRdvOpen(false)}>
                    Annuler
                  </Button>
                  <Button
                    onClick={handleRdvSubmit}
                    disabled={
                      !rdvForm.serviceName ||
                      !rdvForm.date ||
                      !rdvForm.time ||
                      createAppointment.isPending
                    }
                  >
                    {createAppointment.isPending ? 'Enregistrement...' : 'Planifier'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-muted-foreground gap-3">
            <MessageSquare className="h-10 w-10 opacity-30" />
            <p className="text-sm">Sélectionnez une conversation</p>
          </div>
        )}
      </div>
    </div>
  )
}
