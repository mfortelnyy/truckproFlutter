import 'package:truckpro/models/user.dart';

import 'log_entry_type.dart';

class LogEntry {
  final int id;
  final int userId;
  final User? user; 
  final DateTime startTime;
  final DateTime? endTime; 
  final LogEntryType logEntryType;
  final List<String>? imageUrls; 
  final bool isApprovedByManager;

  LogEntry({
    required this.id,
    required this.userId,
    this.user,
    required this.startTime,
    this.endTime,
    required this.logEntryType,
    this.imageUrls,
    required this.isApprovedByManager,
  });

  // Factory method to create a LogEntry from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      userId: json['userId'],
      user: json['user'] !=null ? User.fromJson(json['user']) : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      logEntryType: LogEntryType.values[json['logEntryType']], 
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      isApprovedByManager: json['isApprovedByManager'],
    );
  }

  // Method to convert a LogEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'logEntryType': logEntryType.index,
      'imageUrls': imageUrls,
      'isApprovedByManager': isApprovedByManager,
    };
  }
}

