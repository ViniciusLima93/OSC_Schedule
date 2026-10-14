enum AppointmentStatus { confirmed, cancelled }

/// Inscrição de um morador em uma ação (registrations no backend).
class Appointment {
  Appointment({
    required this.id,
    required this.actionId,
    required this.actionTitle,
    required this.userId,
    required this.moradorName,
    required this.createdAt,
    required this.status,
  });

  final int id;
  final int actionId;
  final String actionTitle;
  final int userId;
  final String moradorName;
  final DateTime createdAt;
  final AppointmentStatus status;

  // Formato de GET /registrations
  factory Appointment.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return Appointment(
      id: json['id'] as int,
      actionId: json['actionId'] as int,
      actionTitle: action?['title'] as String? ?? '',
      userId: json['userId'] as int,
      moradorName: user?['name'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      status: json['status'] == 'cancelada'
          ? AppointmentStatus.cancelled
          : AppointmentStatus.confirmed,
    );
  }
}
