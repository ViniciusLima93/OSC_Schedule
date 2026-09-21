enum AppointmentStatus { pending, confirmed, cancelled }

class Appointment {
  Appointment({
    required this.id,
    required this.actionId,
    required this.moradorName,
    required this.documentIds,
    required this.createdAt,
    this.documentsVerified = false,
    this.status = AppointmentStatus.pending,
  });

  final String id;
  final String actionId;
  final String moradorName;
  final List<String> documentIds;
  final DateTime createdAt;
  bool documentsVerified;
  AppointmentStatus status;
}
