import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  // Get conversations (admin sees all, user sees their own)
  @Get('conversations')
  getConversations(@CurrentUser() user: any) {
    if (user.role === 'admin') {
      return this.chatService.getAllConversations();
    }
    return this.chatService.getUserConversations(user.userId);
  }

  // Create or retrieve existing conversation — consultationId is required
  @Post('conversations')
  createConversation(
    @CurrentUser() user: any,
    @Body() body: { subject?: string; consultationId: string },
  ) {
    if (!body.consultationId) {
      throw new BadRequestException(
        'Une consultation est requise pour démarrer une discussion.',
      );
    }
    return this.chatService.getOrCreateConversation(
      user.userId,
      body.subject,
      body.consultationId,
    );
  }

  // Get a single conversation
  @Get('conversations/:id')
  getConversation(@Param('id') id: string) {
    return this.chatService.getConversationById(id);
  }

  // Get messages in a conversation (REST fallback, real-time via WebSocket)
  @Get('conversations/:id/messages')
  getMessages(@Param('id') id: string) {
    return this.chatService.getMessages(id);
  }
}
