import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ServiceType, PaymentMethod } from '../schemas/consultation.schema';

class KycDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsString()
  phone: string;

  @IsNotEmpty()
  @IsString()
  email: string;

  @IsNotEmpty()
  @IsString()
  city: string;

  @IsNotEmpty()
  @IsString()
  country: string;

  @IsOptional()
  @IsString()
  idDocumentUrl?: string;
}

export class CreateConsultationDto {
  @IsEnum(ServiceType)
  service: ServiceType;

  @IsNotEmpty()
  @IsString()
  subject: string;

  @ValidateNested()
  @Type(() => KycDto)
  kyc: KycDto;

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;
}
