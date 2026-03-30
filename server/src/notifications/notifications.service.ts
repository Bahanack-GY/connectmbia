import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Notification,
  NotificationDocument,
  NotificationType,
} from './schemas/notification.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name)
    private notificationModel: Model<NotificationDocument>,
  ) {}

  async findByUser(userId: string): Promise<NotificationDocument[]> {
    return this.notificationModel
      .find({ userId })
      .sort({ createdAt: -1 })
      .limit(50);
  }

  async createAppointmentNotification(
    userId: string,
    appointmentId: string,
    serviceName: string,
  ): Promise<NotificationDocument> {
    return this.notificationModel.create({
      userId: new Types.ObjectId(userId),
      type: NotificationType.APPOINTMENT_ACCEPTED,
      title: 'Rendez-vous confirmé',
      body: `Votre rendez-vous pour "${serviceName}" a été confirmé.`,
      appointmentId: new Types.ObjectId(appointmentId),
      serviceName,
    });
  }

  async createMessageNotification(
    userId: string,
    conversationId: string,
    senderName: string,
    messagePreview: string,
  ): Promise<NotificationDocument> {
    const preview =
      messagePreview.length > 80
        ? messagePreview.substring(0, 80) + '…'
        : messagePreview;

    return this.notificationModel.create({
      userId: new Types.ObjectId(userId),
      type: NotificationType.NEW_MESSAGE,
      title: senderName,
      body: preview,
      conversationId: new Types.ObjectId(conversationId),
      senderName,
    });
  }

  async markAsRead(notificationId: string): Promise<void> {
    await this.notificationModel.findByIdAndUpdate(notificationId, {
      isRead: true,
    });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notificationModel.updateMany(
      { userId: new Types.ObjectId(userId), isRead: false },
      { isRead: true },
    );
  }
}
