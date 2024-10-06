import 'package:truckpro/models/log_entry_type.dart';
import 'user.dart';

class LogEntry {
  final int id;
  final int userId;
  final User? user;
  final DateTime startTime;
  final DateTime? endTime;
  final LogEntryType logEntryType;
  final List<String>? images; 
  final bool? isApprovedByManager;

  LogEntry({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.logEntryType,
    this.images,
    this.isApprovedByManager,
    this.user,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      logEntryType: LogEntryType.values[json['logEntryType']],
      images: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      isApprovedByManager: json['isApprovedByManager'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(), 
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'logEntryType': logEntryType.index, 
      'imageUrls': images,
      'isApprovedByManager': isApprovedByManager,
    };
  }
}
