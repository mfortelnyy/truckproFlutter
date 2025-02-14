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
  // Parents can be On Duty and Off Duty only 
  //so child Log entries like Break and Driving will have id for the Parent Log it's associated
  final int? parentLogEntryId; 
  //On Duty can contain Driving and Break
  //Off duty can contain Break which will be displayed as 'Sleep'
  final List<LogEntry>? childLogEntries; // New field
  final bool isApprovedByManager;

  LogEntry({
    required this.id,
    required this.userId,
    this.user,
    required this.startTime,
    this.endTime,
    required this.logEntryType,
    this.imageUrls,
    this.parentLogEntryId, 
    this.childLogEntries, 
    required this.isApprovedByManager,
  });

  // Factory method to create a LogEntry from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      logEntryType: LogEntryType.values[json['logEntryType']],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      parentLogEntryId: json['parentLogEntryId'],
      childLogEntries: json['childLogEntries'] != null
          ? (json['childLogEntries'] as List)
              .map((entry) => LogEntry.fromJson(entry))
              .toList()
          : null, 
      isApprovedByManager: json['isApprovedByManager'],
    );
  }

  // Method to convert a LogEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'logEntryType': logEntryType.index,
      'imageUrls': imageUrls,
      'parentLogEntryId': parentLogEntryId, 
      'childLogEntries': childLogEntries?.map((entry) => entry.toJson()).toList(), 
      'isApprovedByManager': isApprovedByManager,
    };
  }
}
