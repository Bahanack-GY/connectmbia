import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  Appointment,
  AppointmentDocument,
  AppointmentStatus,
} from './schemas/appointment.schema';

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectModel(Appointment.name)
    private appointmentModel: Model<AppointmentDocument>,
  ) {}

  async create(data: Partial<Appointment>): Promise<AppointmentDocument> {
    return this.appointmentModel.create(data);
  }

  async findByUser(userId: string): Promise<AppointmentDocument[]> {
    return this.appointmentModel.find({ userId }).sort({ date: 1 });
  }

  async findAll(): Promise<AppointmentDocument[]> {
    return this.appointmentModel
      .find()
      .populate('userId', 'name email phone')
      .sort({ date: 1 });
  }

  async findById(id: string): Promise<AppointmentDocument | null> {
    return this.appointmentModel.findById(id).populate('userId', 'name email phone');
  }

  async updateStatus(
    id: string,
    status: AppointmentStatus,
    meetLink?: string,
    notes?: string,
  ): Promise<AppointmentDocument | null> {
    return this.appointmentModel.findByIdAndUpdate(
      id,
      { status, meetLink, notes },
      { new: true },
    );
  }
}
