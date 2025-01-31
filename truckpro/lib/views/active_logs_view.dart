import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/userDto.dart';
import '../models/log_entry.dart';
import '../models/log_entry_type.dart';

class ActiveLogView extends StatelessWidget {
  final LogEntry activeLog; //only one active log
  final String token;
  final UserDto? userDto;
  final int driverId;
  const ActiveLogView({super.key, required this.token, required this.activeLog, required this.userDto, required this.driverId});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active log details (parent log)
            _buildLogCard(activeLog, isDarkTheme),

            const SizedBox(height: 20),

            // Time Frame 
            _buildTimeline(activeLog),

            const SizedBox(height: 20),

            // Child logs (if any)
            if (activeLog.childLogEntries != null &&
                activeLog.childLogEntries!.isNotEmpty)
              ...activeLog.childLogEntries!.map((childLog) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildChildLogCard(childLog, isDarkTheme),
                );
              }),
          ],
        ),
      ),
    );
  }

  //parent log details
  Widget _buildLogCard(LogEntry log, bool isDarkTheme) {
    return Card(
      elevation: 5,
      color: isDarkTheme ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log type and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${log.logEntryType == LogEntryType.OnDuty ? "On Duty" : "Off Duty"} Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                Icon(
                  log.logEntryType == LogEntryType.OnDuty
                      ? Icons.work
                      : Icons.bedtime,
                  color: log.logEntryType == LogEntryType.OnDuty
                      ? Colors.green
                      : Colors.blue,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 8),
            //Log time and approval status
            Text(
              'Start: ${formatDateTime(log.startTime)}\nEnd: ${log.endTime != null ? formatDateTime(log.endTime!) : "In Progress"}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Approved by Manager: ${log.isApprovedByManager ? "Yes" : "No"}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //child log details
  Widget _buildChildLogCard(LogEntry childLog, bool isDarkTheme) {
    IconData icon;
    String label;

    switch (childLog.logEntryType) {
      case LogEntryType.Driving:
        icon = Icons.directions_car;
        label = "Driving";
        break;
      case LogEntryType.Break:
        icon = Icons.coffee;
        label = "Break";
        break;
      default:
        icon = Icons.bedtime;
        label = "Sleep";
        break;
    }

    return Card(
      elevation: 3,
      color: isDarkTheme ? Colors.grey[700] : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkTheme ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          'Start: ${formatDateTime(childLog.startTime)}\nEnd: ${childLog.endTime != null ? formatDateTime(childLog.endTime!) : "In Progress"}',
          style: TextStyle(
            fontSize: 14,
            color: isDarkTheme ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }

  //timeline for the log
  Widget _buildTimeline(LogEntry log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time Frame",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: log.endTime != null
                  ? log.endTime!.difference(log.startTime).inMinutes.toInt()
                  : 100, 
              child: Container(
                height: 8,
                color: log.logEntryType == LogEntryType.OnDuty
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            if (log.endTime != null)
              Expanded(
                flex: (100 - log.endTime!.difference(log.startTime).inMinutes).toInt(), 
                child: Container(
                  height: 8,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    return formatter.format(dateTime);
  }
}
