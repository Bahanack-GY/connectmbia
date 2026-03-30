class AppointmentModel {
  final String id;
  final String serviceName;
  final String date;
  final String time;
  final String status;
  final String? meetLink;
  final String? notes;

  const AppointmentModel({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    this.meetLink,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['_id']?.toString() ?? '',
        serviceName: json['serviceName']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        meetLink: json['meetLink']?.toString(),
        notes: json['notes']?.toString(),
      );

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulé';
      case 'completed':
        return 'Terminé';
      default:
        return status;
    }
  }
}
