import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../auth/guards/admin.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from './schemas/user.schema';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ── Self ──────────────────────────────────────────────────────────────────

  @Get('me')
  getProfile(@CurrentUser() user: any) {
    return this.usersService.findById(user.userId);
  }

  @Patch('me')
  updateProfile(@CurrentUser() user: any, @Body() body: any) {
    const { password, role, _id, ...safe } = body;
    return this.usersService.updateProfile(user.userId, safe);
  }

  // ── Admin ─────────────────────────────────────────────────────────────────

  @Get()
  @UseGuards(AdminGuard)
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @UseGuards(AdminGuard)
  findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @Patch(':id/role')
  @UseGuards(AdminGuard)
  updateRole(@Param('id') id: string, @Body() body: { role: UserRole }) {
    return this.usersService.updateRole(id, body.role);
  }

  @Delete(':id')
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteUser(@Param('id') id: string) {
    return this.usersService.deleteById(id);
  }
}
