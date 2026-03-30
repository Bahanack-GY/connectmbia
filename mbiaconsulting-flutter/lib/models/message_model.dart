class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['_id']?.toString() ?? '',
        conversationId: json['conversationId']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderRole: json['senderRole']?.toString() ?? 'user',
        text: json['text']?.toString() ?? '',
        isRead: json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  bool get isFromAdmin => senderRole == 'admin';

  String get formattedTime {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
