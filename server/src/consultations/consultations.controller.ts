import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ConsultationsService } from './consultations.service';
import { CreateConsultationDto } from './dto/create-consultation.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ConsultationStatus } from './schemas/consultation.schema';

@Controller('consultations')
@UseGuards(JwtAuthGuard)
export class ConsultationsController {
  constructor(private readonly consultationsService: ConsultationsService) {}

  // User submits a new consultation request (4-step wizard final step)
  @Post()
  create(@CurrentUser() user: any, @Body() dto: CreateConsultationDto) {
    return this.consultationsService.create(user.userId, dto);
  }

  // User fetches their own consultations
  @Get('my')
  findMine(@CurrentUser() user: any) {
    return this.consultationsService.findByUser(user.userId);
  }

  // Admin fetches all consultations
  @Get()
  findAll() {
    return this.consultationsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.consultationsService.findById(id);
  }

  // Admin updates consultation status
  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Body() body: { status: ConsultationStatus; adminNotes?: string },
  ) {
    return this.consultationsService.updateStatus(id, body.status, body.adminNotes);
  }
}
