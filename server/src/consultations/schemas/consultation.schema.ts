import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ConsultationDocument = Consultation & Document;

export enum ServiceType {
  FOOTBALL = 'foot',
  REAL_ESTATE = 'real_estate',
  BUSINESS = 'business',
  CHARITY = 'charity',
}

export enum ConsultationStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  CONFIRMED = 'confirmed',
  REJECTED = 'rejected',
  COMPLETED = 'completed',
}

export enum PaymentMethod {
  ORANGE_MONEY = 'om',
  MTN_MOMO = 'momo',
  CARD = 'card',
}

@Schema({ timestamps: true })
export class Consultation {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ required: true, enum: ServiceType })
  service: ServiceType;

  @Prop({ required: true })
  subject: string;

  @Prop({
    type: {
      name: String,
      phone: String,
      email: String,
      city: String,
      country: String,
      idDocumentUrl: String,
    },
  })
  kyc: {
    name: string;
    phone: string;
    email: string;
    city: string;
    country: string;
    idDocumentUrl?: string;
  };

  @Prop({ enum: PaymentMethod })
  paymentMethod: PaymentMethod;

  @Prop({ unique: true, sparse: true })
  referenceNumber: string;

  @Prop({ default: ConsultationStatus.PENDING, enum: ConsultationStatus })
  status: ConsultationStatus;

  @Prop()
  adminNotes: string;
}

export const ConsultationSchema = SchemaFactory.createForClass(Consultation);
