import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  Consultation,
  ConsultationDocument,
  ConsultationStatus,
} from './schemas/consultation.schema';
import { CreateConsultationDto } from './dto/create-consultation.dto';

@Injectable()
export class ConsultationsService {
  constructor(
    @InjectModel(Consultation.name)
    private consultationModel: Model<ConsultationDocument>,
  ) {}

  async create(
    userId: string,
    dto: CreateConsultationDto,
  ): Promise<ConsultationDocument> {
    return this.consultationModel.create({ ...dto, userId });
  }

  async findByUser(userId: string): Promise<ConsultationDocument[]> {
    return this.consultationModel.find({ userId }).sort({ createdAt: -1 });
  }

  async findAll(): Promise<ConsultationDocument[]> {
    return this.consultationModel
      .find()
      .populate('userId', 'name email phone')
      .sort({ createdAt: -1 });
  }

  async findById(id: string): Promise<ConsultationDocument | null> {
    return this.consultationModel
      .findById(id)
      .populate('userId', 'name email phone');
  }

  async updateStatus(
    id: string,
    status: ConsultationStatus,
    adminNotes?: string,
  ): Promise<ConsultationDocument | null> {
    return this.consultationModel.findByIdAndUpdate(
      id,
      { status, adminNotes },
      { new: true },
    );
  }
}
