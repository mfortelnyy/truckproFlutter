import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
    final parentStartTime = parentLog.startTime;
    final parentEndTime = parentLog.endTime;
    final now = DateTime.now();

    if (parentStartTime == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Log Entry Details'),
        ),
        body: Center(child: Text('Invalid log entry times')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the parent log
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${parentLog.logEntryType} Log Entry',
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
                    const SizedBox(height: 8),
                    // Visualizing the parent log on the timeline
                    Container(
                      height: 50,
                      color: Colors.blue[200],
                      child: Row(
                        children: [
                          Expanded(
                            flex: _getTimelinePosition(parentStartTime),
                            child: Container(color: Colors.transparent),
                          ),
                          Expanded(
                            flex: _getTimelineFlexForEnd(parentStartTime, parentEndTime ?? now),
                            child: Container(color: Colors.blue[600]),
                          ),
                          Expanded(
                            flex: 24 - _getTimelinePosition(parentEndTime ?? now),
                            child: Container(color: Colors.transparent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Display child logs
            Text(
              'Children Logs:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: childrenLogs?.map((log) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${log.logEntryType.toString().split('.').last} Log Entry',
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
                        const SizedBox(height: 8),
                        // Timeline
                        Container(
                          height: 50,
                          color: Colors.green[200],
                          child: Row(
                            children: [
                              Expanded(
                                flex: _getTimelinePosition(log.startTime),
                                child: Container(color: Colors.transparent),
                              ),
                              Expanded(
                                flex: _getTimelineFlexForEnd(log.startTime, log.endTime ?? now),
                                child: Container(color: Colors.green[600]),
                              ),
                              Expanded(
                                flex: 24 - _getTimelinePosition(log.endTime ?? now),
                                child: Container(color: Colors.transparent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList() ?? [],
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
      return 'In Progress'; // For active logs
    }
  }

  int _getTimelinePosition(DateTime time) {
    final startOfDay = DateTime(time.year, time.month, time.day, 0, 0, 0);
    final duration = time.difference(startOfDay).inMinutes;
    return (duration / 60).round();
  }

  int _getTimelineFlexForEnd(DateTime startTime, DateTime endTime) {
    final startFlex = _getTimelinePosition(startTime);
    final endFlex = _getTimelinePosition(endTime);
    return endFlex - startFlex > 0 ? endFlex - startFlex : 1; 
  }
}
