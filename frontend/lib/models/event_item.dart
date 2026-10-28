class EventItem {
  const EventItem({
    required this.id,
    required this.name,
    required this.duration,
    required this.description,
    required this.applicantCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String duration;
  final String description;
  final int applicantCount;
  final DateTime createdAt;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as int,
      name: json['name'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String,
      applicantCount: json['applicantCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}