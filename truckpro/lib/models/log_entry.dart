class LogEntry {
  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final String logEntryType;
  final List<String>? images;

  LogEntry({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.logEntryType,
    this.images,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      logEntryType: json['logEntryType'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'logEntryType': logEntryType,
      'images': images,
    };
  }
}
