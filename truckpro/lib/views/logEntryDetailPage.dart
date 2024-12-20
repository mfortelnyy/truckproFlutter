import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/views/custom_timeline.dart';

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
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Log Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 8, // Added shadow for better separation
              color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
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
                    // Custom Timeline Visualization for Parent Log
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

            //Child Log Timeline with Divider
            Expanded(
              child: ListView.builder(
                itemCount: childrenLogs?.length ?? 0,
                itemBuilder: (context, index) {
                  final log = childrenLogs![index];
                  return Column(
                    children: [
                      _buildTimelineItem(log),
                      // Divider after each log with padding to make it distinct
                      if (index < (childrenLogs?.length ?? 0) - 1) 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 3,  // Divider height
                            color: Colors.grey.withOpacity(0.5), 
                          ),
                        ),
                    ],
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

  //adds a space before uppercase letters (format LogEntry type)
  String _formatLogEntryType(String type) {
    return type.replaceAllMapped(RegExp(r'(?<!^)([A-Z])'), (match) => ' ${match.group(0)}');
  }

  //TimelineItem for each child log
  Widget _buildTimelineItem(LogEntry log) {
    IconData icon;
    Color color;

    switch (log.logEntryType) {
      case LogEntryType.Break:
        icon = Icons.pause;
        color = Colors.yellow[600]!;
        break;
      case LogEntryType.Driving:
        icon = Icons.drive_eta;
        color = Colors.green[400]!;
        break;
      case LogEntryType.OnDuty:
        icon = Icons.access_alarm;
        color = Colors.orange[400]!;
        break;
      case LogEntryType.OffDuty:
        icon = Icons.ac_unit_outlined;
        color = Colors.blue[400]!;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey[400]!;
    }

    return TimelineTile(
      alignment: TimelineAlign.start,
      lineXY: 0.1,
      indicatorStyle: IndicatorStyle(
        color: color,
        width: 32,  
        iconStyle: IconStyle(
          iconData: icon,
          color: Colors.white,
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatLogEntryType(log.logEntryType.toString().split(".").last),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${formatDateTime(log.startTime)}\nEnd: ${formatDateTime(log.endTime)}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
