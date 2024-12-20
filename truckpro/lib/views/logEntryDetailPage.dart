import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';

class LogEntryDetailPage extends StatelessWidget {
  final LogEntry parentLog;
  final List<LogEntry>? childrenLogs;

  const LogEntryDetailPage({
    Key? key,
    required this.parentLog,
    required this.childrenLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final parentStartTime = parentLog.startTime!;
    final parentEndTime = parentLog.endTime ?? DateTime.now();

    final logColors = {
      'driving': Colors.green[400]!,
      'break': Colors.yellow[600]!,
      'sleep': Colors.yellow[600]!, // break and sleep use the same color
      'parent': Colors.blue[400]!,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Log Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatLogEntryType(parentLog.logEntryType.toString().split(".").last)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start: ${formatDateTime(parentStartTime)}\nEnd: ${formatDateTime(parentEndTime)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkTheme ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Timeline Visualization
                    CustomTimeline(
                      parentStartTime: parentStartTime,
                      parentEndTime: parentEndTime,
                      childrenLogs: childrenLogs,
                      logColors: logColors,
                    ),
                  ],
                ),
              ),
            ),

            // Events Legend
            Text(
              'Events:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Child Log List
            Expanded(
              child: ListView.builder(
                itemCount: childrenLogs?.length ?? 0,
                itemBuilder: (context, index) {
                  final log = childrenLogs![index];
                  final logType = log.logEntryType.toString().split('.').last.toLowerCase();
                  final color = logColors[logType] ?? Colors.grey[400]!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Color indicator for log type
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Log details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.logEntryType == LogEntryType.Break && parentLog.logEntryType == LogEntryType.OffDuty
                                  ? 'Sleep'
                                  : '${log.logEntryType.toString().split('.').last}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start: ${formatDateTime(log.startTime)}\nEnd: ${formatDateTime(log.endTime)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkTheme ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
      return formatter.format(dateTime);
    } else {
      return 'In Progress';
    }
  }

  // Adds a space before uppercase letters
  String _formatLogEntryType(String type) {
    return type.replaceAllMapped(RegExp(r'(?<!^)([A-Z])'), (match) => ' ${match.group(0)}');
  }
}

// Custom Timeline Widget
class CustomTimeline extends StatelessWidget {
  final DateTime parentStartTime;
  final DateTime parentEndTime;
  final List<LogEntry>? childrenLogs;
  final Map<String, Color> logColors;

  const CustomTimeline({
    Key? key,
    required this.parentStartTime,
    required this.parentEndTime,
    required this.childrenLogs,
    required this.logColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDuration = parentEndTime.difference(parentStartTime).inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            // Parent timeline (base line)
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Children log segments
            ...?childrenLogs?.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              final logType = log.logEntryType.toString().split('.').last.toLowerCase();
              final logColor = logColors[logType] ?? Colors.grey[400]!;

              final startOffset = log.startTime.difference(parentStartTime).inMinutes / totalDuration;
              final endOffset = log.endTime?.difference(parentStartTime).inMinutes ?? 0 / totalDuration;

              return Positioned(
                left: startOffset * 100,
                width: (endOffset - startOffset) * 100,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: logColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        // Time labels underneath the timeline
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDateTime(parentStartTime), style: const TextStyle(fontSize: 10)),
            Text(formatDateTime(parentEndTime), style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat('MM/dd/yyyy h:mma').format(dateTime);
    } else {
      return 'N/A';
    }
  }
}
