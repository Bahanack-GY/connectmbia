import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AppointmentStatus } from './schemas/appointment.schema';
import { NotificationsService } from '../notifications/notifications.service';

@Controller('appointments')
@UseGuards(JwtAuthGuard)
export class AppointmentsController {
  constructor(
    private readonly appointmentsService: AppointmentsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  // User creates an appointment (usually triggered after consultation is confirmed)
  @Post()
  create(@CurrentUser() user: any, @Body() body: any) {
    const { _id, ...safe } = body;
    return this.appointmentsService.create({ ...safe, userId: user.userId });
  }

  // User fetches their appointments
  @Get('my')
  findMine(@CurrentUser() user: any) {
    return this.appointmentsService.findByUser(user.userId);
  }

  // Admin fetches all appointments
  @Get()
  findAll() {
    return this.appointmentsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.appointmentsService.findById(id);
  }

  // Admin updates appointment status, meet link, notes
  @Patch(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body()
    body: {
      status: AppointmentStatus;
      meetLink?: string;
      notes?: string;
    },
  ) {
    const appointment = await this.appointmentsService.updateStatus(
      id,
      body.status,
      body.meetLink,
      body.notes,
    );

    // Notify user when appointment is confirmed
    if (appointment && body.status === AppointmentStatus.CONFIRMED) {
      await this.notificationsService.createAppointmentNotification(
        appointment.userId.toString(),
        appointment._id.toString(),
        appointment.serviceName,
      );
    }

    return appointment;
  }
}
