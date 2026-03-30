import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;
    if (!user || user.role !== 'admin') {
      throw new ForbiddenException('Accès réservé aux administrateurs');
    }
    return true;
  }
}
