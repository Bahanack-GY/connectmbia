import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { ConsultationsService } from '../consultations/consultations.service';
import { AppointmentsService } from '../appointments/appointments.service';
import { ChatService } from '../chat/chat.service';
import { NotificationsService } from '../notifications/notifications.service';

export interface CreateAppointmentForUserDto {
  userId: string;
  adminId: string;
  conversationId?: string;
  serviceName: string;
  date: string;
  time: string;
  meetLink?: string;
  notes?: string;
}

@Injectable()
export class AdminService {
  constructor(
    private readonly usersService: UsersService,
    private readonly consultationsService: ConsultationsService,
    private readonly appointmentsService: AppointmentsService,
    private readonly chatService: ChatService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async createAppointmentForUser(dto: CreateAppointmentForUserDto) {
    const appointment = await this.appointmentsService.create({
      userId: dto.userId as any,
      serviceName: dto.serviceName,
      date: dto.date,
      time: dto.time,
      meetLink: dto.meetLink,
      notes: dto.notes,
    });

    // Notify the user about their new appointment
    await this.notificationsService.createAppointmentNotification(
      dto.userId,
      appointment._id.toString(),
      dto.serviceName,
    );

    if (dto.conversationId) {
      await this.chatService.sendMessage(
        dto.conversationId,
        dto.adminId,
        'admin',
        `Rendez-vous planifié le ${dto.date} à ${dto.time} — ${dto.serviceName}.${dto.meetLink ? ` Lien : ${dto.meetLink}` : ''}`,
      );
    }

    return appointment;
  }

  async getStats() {
    const [users, consultations, appointments, conversations] = await Promise.all([
      this.usersService.findAll(),
      this.consultationsService.findAll(),
      this.appointmentsService.findAll(),
      this.chatService.getAllConversations(),
    ]);

    const consultationsByStatus = consultations.reduce(
      (acc, c) => {
        acc[c.status] = (acc[c.status] ?? 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    const appointmentsByStatus = appointments.reduce(
      (acc, a) => {
        acc[a.status] = (acc[a.status] ?? 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    const totalUnread = conversations.reduce(
      (sum, c) => sum + (c.unreadCount ?? 0),
      0,
    );

    return {
      users: {
        total: users.length,
        clients: users.filter((u) => u.role !== 'admin').length,
        admins: users.filter((u) => u.role === 'admin').length,
      },
      consultations: {
        total: consultations.length,
        pending: consultationsByStatus['pending'] ?? 0,
        in_progress: consultationsByStatus['in_progress'] ?? 0,
        confirmed: consultationsByStatus['confirmed'] ?? 0,
        rejected: consultationsByStatus['rejected'] ?? 0,
        completed: consultationsByStatus['completed'] ?? 0,
      },
      appointments: {
        total: appointments.length,
        pending: appointmentsByStatus['pending'] ?? 0,
        confirmed: appointmentsByStatus['confirmed'] ?? 0,
        cancelled: appointmentsByStatus['cancelled'] ?? 0,
        completed: appointmentsByStatus['completed'] ?? 0,
      },
      conversations: {
        total: conversations.length,
        unread: totalUnread,
      },
    };
  }
}
