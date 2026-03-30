import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { networkInterfaces } from 'os';
import { AppModule } from './app.module';

function getLanIp(): string {
  const nets = networkInterfaces();
  for (const iface of Object.values(nets)) {
    for (const net of iface ?? []) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'localhost';
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  app.enableCors({ origin: '*', credentials: true });

  const port = process.env.PORT ?? 3000;

  // Bind to 0.0.0.0 so the server is reachable from any network interface
  await app.listen(port, '0.0.0.0');

  const lanIp = getLanIp();
  console.log(`\n Server ready:`);
  console.log(`   Local:   http://localhost:${port}/api`);
  console.log(`   Network: http://${lanIp}:${port}/api`);
  console.log(`\n Flutter config (physical device / LAN):`);
  console.log(`   static const String _host = '${lanIp}';\n`);
}
bootstrap();
