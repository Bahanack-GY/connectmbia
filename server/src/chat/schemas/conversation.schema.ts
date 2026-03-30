import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ConversationDocument = Conversation & Document;

@Schema({ timestamps: true })
export class Conversation {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ default: 'Nouvelle discussion' })
  subject: string;

  @Prop({ type: Types.ObjectId, ref: 'Consultation' })
  consultationId: Types.ObjectId;

  @Prop({ default: '' })
  lastMessage: string;

  @Prop({ default: 0 })
  unreadCount: number;

  @Prop({ default: true })
  isActive: boolean;
}

export const ConversationSchema = SchemaFactory.createForClass(Conversation);
