class AppConstants {
  // ── Set the host for your environment ──────────────────────────────────────
  //
  // Physical device or any device on the same LAN (current machine IP):
 static const String _host = 'connectmbiabeta-api.mylisapp.online';
  // static const String _host = '192.168.1.185:3000';

  //
  // Android emulator only → uncomment and use 10.0.2.2 instead:
  // static const String _host = '10.0.2.2';
  //
  // iOS simulator only → uncomment and use localhost instead:
  // static const String _host = 'localhost';
  //
  // The server prints its current LAN IP at startup — update _host if it changes.
  // ───────────────────────────────────────────────────────────────────────────

  static const int _port = 3000;

  static const String baseUrl = 'https://$_host/api';
  static const String socketUrl = 'https://$_host';
}
