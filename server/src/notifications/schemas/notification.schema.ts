import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type NotificationDocument = Notification & Document;

export enum NotificationType {
  APPOINTMENT_ACCEPTED = 'appointment_accepted',
  NEW_MESSAGE = 'new_message',
}

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ required: true, enum: NotificationType })
  type: NotificationType;

  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  body: string;

  @Prop({ default: false })
  isRead: boolean;

  // For appointment notifications
  @Prop({ type: Types.ObjectId, ref: 'Appointment' })
  appointmentId: Types.ObjectId;

  @Prop()
  serviceName: string;

  // For message notifications
  @Prop({ type: Types.ObjectId, ref: 'Conversation' })
  conversationId: Types.ObjectId;

  @Prop()
  senderName: string;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
