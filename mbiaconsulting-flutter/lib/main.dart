import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/socket_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final socketService = SocketService();
  final authProvider = AuthProvider(socketService);

  // Auto-logout when the server returns 401 (token expired).
  // Deferred to next frame so the current widget lifecycle completes first.
  ApiService.onUnauthorized = () {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.isAuthenticated) authProvider.signOut();
    });
  };

  // Restore session before painting the first frame
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(
            socketService: socketService,
            getToken: () => authProvider.token,
          ),
        ),
      ],
      child: const MbiaConsultingApp(),
    ),
  );
}

class MbiaConsultingApp extends StatelessWidget {
  const MbiaConsultingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stéphane Mbia Consulting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Auth-aware root: listen to AuthProvider to switch between screens
      home: Consumer<AuthProvider>(
        builder: (_, auth, _) {
          if (auth.isInitializing) {
            return const _SplashScreen();
          }
          return auth.isAuthenticated
              ? const MainScreen()
              : const SignInScreen();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
