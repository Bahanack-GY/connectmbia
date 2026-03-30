import { useQuery } from '@tanstack/react-query'
import { chatApi } from './api'

export const CHAT_KEYS = {
  conversations: ['chat', 'conversations'] as const,
  messages: (id: string) => ['chat', 'messages', id] as const,
}

export function useConversations() {
  return useQuery({
    queryKey: CHAT_KEYS.conversations,
    queryFn: chatApi.conversations,
    staleTime: 15 * 1000,
    refetchInterval: 30 * 1000,
  })
}

export function useMessages(conversationId: string | null) {
  return useQuery({
    queryKey: CHAT_KEYS.messages(conversationId ?? ''),
    queryFn: () => chatApi.messages(conversationId!),
    enabled: !!conversationId,
    staleTime: 0,
  })
}
