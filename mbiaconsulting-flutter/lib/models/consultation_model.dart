class ConsultationModel {
  final String id;
  final String referenceNumber;
  final String service;
  final String subject;
  final String status;
  final String? paymentMethod;
  final String clientName;
  final String clientEmail;
  final String createdAt;

  const ConsultationModel({
    required this.id,
    required this.referenceNumber,
    required this.service,
    required this.subject,
    required this.status,
    required this.clientName,
    required this.clientEmail,
    required this.createdAt,
    this.paymentMethod,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    final kyc = json['kyc'] as Map<String, dynamic>? ?? {};
    return ConsultationModel(
      id: json['_id']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString() ?? json['_id']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString(),
      clientName: kyc['name']?.toString() ?? '',
      clientEmail: kyc['email']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  String get serviceLabel {
    switch (service) {
      case 'foot':
        return 'Gestion Patrimoine Sportif';
      case 'real_estate':
        return 'Infrastructure & BTP';
      case 'business':
        return 'Conseil & Stratégie';
      case 'charity':
        return 'Fondation & Philanthropie';
      default:
        return subject;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      case 'confirmed':
        return 'Confirmée';
      case 'rejected':
        return 'Refusée';
      case 'completed':
        return 'Terminée';
      default:
        return status;
    }
  }

  String get paymentLabel {
    switch (paymentMethod) {
      case 'om':
        return 'Orange Money';
      case 'momo':
        return 'MTN MoMo';
      case 'card':
        return 'Carte bancaire';
      default:
        return paymentMethod ?? '';
    }
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}
