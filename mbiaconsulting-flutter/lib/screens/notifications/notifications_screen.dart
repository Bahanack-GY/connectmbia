import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/notification_model.dart';
import '../chat/chat_detail_screen.dart';
import '../profile/appointments_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token;
      final data =
          await ApiService(token: token).get('/notifications') as List<dynamic>;
      setState(() {
        _notifications = data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onNotificationTap(NotificationModel notif) {
    if (notif.isAppointment) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
      );
    } else if (notif.isMessage && notif.conversationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            conversationId: notif.conversationId!,
            title: notif.senderName ?? 'Discussion',
            status: '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.gold,
          strokeWidth: 1.5,
        ),
      );
    }

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _loadNotifications,
      );
    }

    if (_notifications.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      onRefresh: _loadNotifications,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _NotificationCard(
          notification: _notifications[index],
          onTap: () => _onNotificationTap(_notifications[index]),
        ),
      ),
    );
  }
}

// ── Notification Card ────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isUnread
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: notification.isAppointment
                    ? Colors.green.withValues(alpha: 0.12)
                    : AppTheme.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: notification.isAppointment
                      ? Colors.green.withValues(alpha: 0.3)
                      : AppTheme.gold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                notification.isAppointment
                    ? Icons.event_available_rounded
                    : Icons.chat_bubble_rounded,
                color: notification.isAppointment
                    ? Colors.green
                    : AppTheme.gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.formattedTime,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color:
                              isUnread ? AppTheme.gold : AppTheme.textMuted,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isUnread
                          ? Colors.white.withValues(alpha: 0.75)
                          : AppTheme.textMuted,
                      fontWeight:
                          isUnread ? FontWeight.w500 : FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Action hint
                  Row(
                    children: [
                      Icon(
                        notification.isAppointment
                            ? Icons.calendar_month_outlined
                            : Icons.arrow_forward_rounded,
                        size: 13,
                        color: AppTheme.gold.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.isAppointment
                            ? 'Voir mes rendez-vous'
                            : 'Ouvrir la discussion',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.gold.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Unread dot
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.gold.withValues(alpha: 0.6),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune notification',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vos notifications de rendez-vous\net de messages apparaîtront ici.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              size: 44,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: AppTheme.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Réessayer',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
