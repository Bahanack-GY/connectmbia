import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Conversation,
  ConversationDocument,
} from './schemas/conversation.schema';
import { Message, MessageDocument } from './schemas/message.schema';

@Injectable()
export class ChatService {
  constructor(
    @InjectModel(Conversation.name)
    private conversationModel: Model<ConversationDocument>,
    @InjectModel(Message.name)
    private messageModel: Model<MessageDocument>,
  ) {}

  async getOrCreateConversation(
    userId: string,
    subject?: string,
    consultationId?: string,
  ): Promise<ConversationDocument> {
    const filter: any = { userId };
    if (consultationId) filter.consultationId = new Types.ObjectId(consultationId);

    let conversation = await this.conversationModel.findOne(filter);
    if (!conversation) {
      conversation = await this.conversationModel.create({
        userId,
        subject: subject || 'Nouvelle discussion',
        consultationId: consultationId
          ? new Types.ObjectId(consultationId)
          : undefined,
        isActive: true,
      });
    }
    return conversation;
  }

  async getUserConversations(userId: string): Promise<ConversationDocument[]> {
    return this.conversationModel
      .find({ userId })
      .sort({ updatedAt: -1 });
  }

  async getAllConversations(): Promise<ConversationDocument[]> {
    return this.conversationModel
      .find()
      .populate('userId', 'name email avatar')
      .sort({ updatedAt: -1 });
  }

  async getMessages(conversationId: string): Promise<MessageDocument[]> {
    return this.messageModel
      .find({ conversationId: new Types.ObjectId(conversationId) })
      .sort({ createdAt: 1 });
  }

  async sendMessage(
    conversationId: string,
    senderId: string,
    senderRole: string,
    text: string,
  ): Promise<MessageDocument> {
    const message = await this.messageModel.create({
      conversationId: new Types.ObjectId(conversationId),
      senderId: new Types.ObjectId(senderId),
      senderRole,
      text,
    });

    // Update conversation last message + increment unread for user if admin sent
    const unreadIncrement = senderRole === 'admin' ? 1 : 0;
    await this.conversationModel.findByIdAndUpdate(conversationId, {
      lastMessage: text,
      $inc: { unreadCount: unreadIncrement },
    });

    return message;
  }

  async markAsRead(conversationId: string): Promise<void> {
    await this.messageModel.updateMany(
      { conversationId: new Types.ObjectId(conversationId), isRead: false },
      { isRead: true },
    );
    await this.conversationModel.findByIdAndUpdate(conversationId, {
      unreadCount: 0,
    });
  }

  async getConversationById(id: string): Promise<ConversationDocument | null> {
    return this.conversationModel
      .findById(id)
      .populate('userId', 'name email avatar');
  }
}
