class NotificationModel {
  final String id;
  final String type; // 'appointment_accepted', 'new_message'
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  // For appointment notifications
  final String? appointmentId;
  final String? serviceName;

  // For message notifications
  final String? conversationId;
  final String? senderName;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.appointmentId,
    this.serviceName,
    this.conversationId,
    this.senderName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] == true,
      appointmentId: json['appointmentId']?.toString(),
      serviceName: json['serviceName']?.toString(),
      conversationId: json['conversationId']?.toString(),
      senderName: json['senderName']?.toString(),
    );
  }

  bool get isAppointment => type == 'appointment_accepted';
  bool get isMessage => type == 'new_message';

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return "A l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}';
  }
}
