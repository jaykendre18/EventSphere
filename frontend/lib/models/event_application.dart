class EventApplication {
  const EventApplication({
    required this.id,
    required this.eventId,
    required this.applicantName,
    required this.reason,
    required this.appliedAt,
  });

  final int id;
  final int eventId;
  final String applicantName;
  final String reason;
  final DateTime appliedAt;

  factory EventApplication.fromJson(Map<String, dynamic> json) {
    return EventApplication(
      id: json['id'] as int,
      eventId: json['eventId'] as int,
      applicantName: json['applicantName'] as String,
      reason: json['reason'] as String,
      appliedAt: DateTime.tryParse(json['appliedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}