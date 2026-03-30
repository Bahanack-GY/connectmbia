import { Body, Controller, Get, Post, Request, UseGuards } from '@nestjs/common';
import { AdminService, CreateAppointmentForUserDto } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../auth/guards/admin.guard';

@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('stats')
  getStats() {
    return this.adminService.getStats();
  }

  @Post('appointments')
  createAppointment(
    @Body() body: Omit<CreateAppointmentForUserDto, 'adminId'>,
    @Request() req: any,
  ) {
    return this.adminService.createAppointmentForUser({
      ...body,
      adminId: req.user.userId,
    });
  }
}
