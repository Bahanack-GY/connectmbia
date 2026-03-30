import { api } from '@/lib/api'
import { SOCKET_URL } from '@/config/env'
import { io, type Socket } from 'socket.io-client'

export interface Conversation {
  _id: string
  subject: string
  lastMessage: string
  unreadCount: number
  isActive: boolean
  updatedAt: string
  userId: { _id: string; name?: string; email?: string } | string
}

export interface Message {
  _id: string
  text: string
  senderRole: string
  senderId: string
  createdAt: string
  isRead: boolean
}

export const chatApi = {
  conversations: () => api.get<Conversation[]>('/chat/conversations'),
  messages: (conversationId: string) =>
    api.get<Message[]>(`/chat/conversations/${conversationId}/messages`),
}

/** Create a new authenticated socket. Caller is responsible for disconnecting it. */
export function createChatSocket(): Socket {
  const token = localStorage.getItem('admin_token')
  return io(`${SOCKET_URL}/chat`, {
    auth: { token },
    transports: ['websocket'],
  })
}
