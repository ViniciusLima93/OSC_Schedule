class SocialAction {
  SocialAction({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.totalSlots,
    required this.requiredDocuments,
    this.bookedSlots = 0,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final int totalSlots;
  final List<String> requiredDocuments;
  int bookedSlots;

  int get availableSlots => totalSlots - bookedSlots;
  bool get isFull => availableSlots <= 0;
}
