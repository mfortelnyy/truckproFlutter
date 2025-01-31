import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';

class LogBarChart extends StatelessWidget {
  final LogEntry parentLog;
  final List<LogEntry> childLogs;
  final Map<String, Color> logColors;

  const LogBarChart({
    super.key,
    required this.parentLog,
    required this.childLogs,
    required this.logColors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentStartTime = parentLog.startTime;
        final parentEndTime = parentLog.endTime ?? DateTime.now();

        // Calculate the total duration of the parent log in seconds
        final totalDuration =
            parentEndTime.difference(parentStartTime).inSeconds.toDouble();

        // Return a CustomPaint widget to render the log bar chart
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, 10),  // Adjust bar height here
              painter: _LogBarPainter(
                parentStartTime: parentStartTime,
                totalDuration: totalDuration,
                childLogs: childLogs,
                logColors: logColors,
                isParentOffDuty: parentLog.logEntryType.toString().split('.').last.toLowerCase() == 'offduty',
              ),
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
      },
    );
  }

  String formatDateTime(DateTime dateTime) {
    // Formats DateTime to a human-readable string
    return "${dateTime.hour}:${dateTime.minute}"; 
  }
}

class _LogBarPainter extends CustomPainter {
  final DateTime parentStartTime;
  final double totalDuration; // in seconds
  final List<LogEntry> childLogs;
  final Map<String, Color> logColors;
  final bool isParentOffDuty;

  _LogBarPainter({
    required this.parentStartTime,
    required this.totalDuration,
    required this.childLogs,
    required this.logColors,
    required this.isParentOffDuty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = logColors['parent']!
      ..style = PaintingStyle.fill;

    final Paint segmentPaint = Paint()..style = PaintingStyle.fill;

    // Draw the background bar (entire parent log duration)
    final barHeight = size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, barHeight),
      backgroundPaint,
    );

    for (var log in childLogs) {
      final startTime = log.startTime;
      final endTime = log.endTime ?? DateTime.now();

      // Ensure the log's start and end times are within the parent log's range
      if (startTime.isBefore(parentStartTime) ||
          endTime.isAfter(parentStartTime.add(Duration(seconds: totalDuration.toInt())))) {
        continue;
      }

      // Calculate relative positions (0 to 1 scale) for the child log
      final startFraction = (startTime.difference(parentStartTime).inSeconds / totalDuration).clamp(0.0, 1.0);
      final endFraction = (endTime.difference(parentStartTime).inSeconds / totalDuration).clamp(0.0, 1.0);

      // Convert relative positions to pixel positions
      final left = startFraction * size.width;
      final right = endFraction * size.width;

      // Determine the appropriate color
      String logType = log.logEntryType.toString().split('.').last.toLowerCase();
      if (logType == 'break' && isParentOffDuty) {
        logType = 'sleep';
      }

      segmentPaint.color = logColors[logType] ?? Colors.grey;

      // Draw the segment
      canvas.drawRect(
        Rect.fromLTWH(left, 0, right - left, barHeight),
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
