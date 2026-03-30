import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { ChatService } from './chat.service';
import { NotificationsService } from '../notifications/notifications.service';

@WebSocketGateway({
  cors: { origin: '*', credentials: true },
  namespace: '/chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private readonly chatService: ChatService,
    private readonly jwtService: JwtService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token =
        (client.handshake.auth?.token as string) ||
        (client.handshake.headers?.authorization as string)?.replace(
          'Bearer ',
          '',
        );

      if (!token) {
        client.emit('error', { message: 'Token manquant' });
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);
      client.data.user = {
        userId: String(payload.sub),
        email: payload.email,
        role: payload.role,
      };

      console.log(
        `[Chat] Connected: ${client.id} (${payload.email}, role=${payload.role})`,
      );

      // Admin joins the global admin room to get notified of any new message
      if (payload.role === 'admin') {
        client.join('admin_room');
      }
    } catch {
      client.emit('error', { message: 'Token invalide' });
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const user = client.data?.user;
    console.log(`[Chat] Disconnected: ${client.id} (${user?.email ?? 'unknown'})`);
  }

  // Client joins a conversation room and receives message history
  @SubscribeMessage('join_conversation')
  async handleJoinConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() conversationId: string,
  ) {
    const room = `conversation:${conversationId}`;
    client.join(room);

    // Mark messages as read when joining
    await this.chatService.markAsRead(conversationId);

    const messages = await this.chatService.getMessages(conversationId);
    client.emit('message_history', messages);

    console.log(`[Chat] ${client.id} joined room ${room}`);
  }

  // Client leaves a conversation room
  @SubscribeMessage('leave_conversation')
  handleLeaveConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() conversationId: string,
  ) {
    client.leave(`conversation:${conversationId}`);
  }

  // Send a message in a conversation
  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string; text: string },
  ) {
    const user = client.data?.user;
    if (!user || !data.conversationId || !data.text?.trim()) return;

    const message = await this.chatService.sendMessage(
      data.conversationId,
      user.userId,
      user.role,
      data.text.trim(),
    );

    const room = `conversation:${data.conversationId}`;

    // Broadcast the message to everyone in the conversation room
    this.server.to(room).emit('new_message', message);

    // Also notify admin room so the admin panel updates its list
    if (user.role === 'user') {
      this.server.to('admin_room').emit('conversation_updated', {
        conversationId: data.conversationId,
        lastMessage: data.text.trim(),
      });
    }

    // Create notification for user when admin sends a message
    if (user.role === 'admin') {
      const conversation = await this.chatService.getConversationById(
        data.conversationId,
      );
      if (conversation) {
        await this.notificationsService.createMessageNotification(
          conversation.userId.toString(),
          data.conversationId,
          'Equipe Connect Mbia',
          data.text.trim(),
        );
      }
    }

    return message;
  }

  // Mark all messages in a conversation as read
  @SubscribeMessage('mark_read')
  async handleMarkRead(
    @ConnectedSocket() client: Socket,
    @MessageBody() conversationId: string,
  ) {
    await this.chatService.markAsRead(conversationId);
    this.server
      .to(`conversation:${conversationId}`)
      .emit('messages_read', { conversationId });
  }
}
