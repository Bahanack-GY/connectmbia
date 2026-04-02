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

  private generateReference(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const random = Math.floor(1000 + Math.random() * 9000);
    return `SMC-${year}${month}-${random}`;
  }

  async create(
    userId: string,
    dto: CreateConsultationDto,
  ): Promise<ConsultationDocument> {
    const referenceNumber = this.generateReference();
    return this.consultationModel.create({ ...dto, userId, referenceNumber });
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
