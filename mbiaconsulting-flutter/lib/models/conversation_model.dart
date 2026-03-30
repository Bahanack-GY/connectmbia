class ConversationModel {
  final String id;
  final String userId;
  final String subject;
  final String lastMessage;
  final int unreadCount;
  final bool isActive;
  final DateTime updatedAt;
  // Populated when admin fetches conversations (userId is an object)
  final String? userName;
  final String? userEmail;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.lastMessage,
    required this.unreadCount,
    required this.isActive,
    required this.updatedAt,
    this.userName,
    this.userEmail,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['userId'];
    String userId = '';
    String? userName;
    String? userEmail;

    if (rawUserId is String) {
      userId = rawUserId;
    } else if (rawUserId is Map<String, dynamic>) {
      userId = rawUserId['_id']?.toString() ?? '';
      userName = rawUserId['name']?.toString();
      userEmail = rawUserId['email']?.toString();
    }

    return ConversationModel(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      subject: json['subject']?.toString() ?? 'Nouvelle discussion',
      lastMessage: json['lastMessage']?.toString() ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      userName: userName,
      userEmail: userEmail,
    );
  }

  String get displayTitle => userName ?? subject;

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inDays == 0) {
      return '${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[updatedAt.weekday - 1];
    }
    return '${updatedAt.day}/${updatedAt.month}';
  }
}
