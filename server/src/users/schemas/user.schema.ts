import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ trim: true })
  phone: string;

  @Prop({ required: true })
  password: string;

  @Prop({ default: UserRole.USER, enum: UserRole })
  role: UserRole;

  @Prop()
  avatar: string;
}

export const UserSchema = SchemaFactory.createForClass(User);
