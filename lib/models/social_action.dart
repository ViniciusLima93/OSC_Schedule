class SocialAction {
  SocialAction({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.totalSlots,
    required this.requiredDocuments,
    this.bookedSlots = 0,
  });

  final int id;
  final int organizerId;
  final String organizerName;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final int totalSlots;
  final List<String> requiredDocuments;
  final int bookedSlots;

  int get availableSlots => totalSlots - bookedSlots;
  bool get isFull => availableSlots <= 0;
  bool get isPast => dateTime.isBefore(DateTime.now());

  // Formato de GET /actions
  factory SocialAction.fromJson(Map<String, dynamic> json) {
    final organizer = json['organizer'] as Map<String, dynamic>?;
    return SocialAction(
      id: json['id'] as int,
      organizerId: json['organizerId'] as int,
      organizerName: organizer?['name'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      dateTime: DateTime.parse(json['eventDate'] as String).toLocal(),
      totalSlots: json['vacancies'] as int,
      requiredDocuments: List<String>.from(json['docs'] as List? ?? const []),
      bookedSlots: json['registered'] as int? ?? 0,
    );
  }
}
