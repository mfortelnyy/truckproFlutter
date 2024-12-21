import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/log_entry.dart';

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
    final totalDuration = parentEndTime.difference(parentStartTime).inMinutes.toDouble();
    final totalWidth = MediaQuery.of(context).size.width - 10; // Full width of the timeline in pixels
    final minSegmentWidth = 1.0; // Minimum width for a very short log segment
    final maxEventsPerWidth = 10; // Max number of events before scaling

    // Calculate the scale factor based on the number of events
    double scaleFactor = 1.0;
    if (childrenLogs != null && childrenLogs!.length > maxEventsPerWidth) {
      scaleFactor = totalWidth / (totalWidth / (childrenLogs!.length * minSegmentWidth));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            // Parent timeline (base line)
            Container(
              height: 10,
              width: totalWidth, // Ensures the parent timeline spans the full width
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5), // Fully rounded corners
              ),
            ),
            // Children log segments
            ...?childrenLogs?.asMap().entries.map((entry) {
              final log = entry.value;
              final logType = log.logEntryType.toString().split('.').last.toLowerCase();
              final logColor = logColors[logType] ?? Colors.grey[400]!;

              // Calculate the offsets for start and end of each child log as a proportion of the total duration
              var startOffset = (log.startTime.difference(parentStartTime).inMinutes / totalDuration);
           var endOffset = log.endTime != null
                ? (log.endTime!.difference(parentStartTime).inMinutes / totalDuration)
                : (DateTime.now().difference(parentStartTime).inMinutes / totalDuration);
              // Clamp offsets to ensure they stay within 0.0 to 1.0 range
              startOffset = startOffset.clamp(0.0, 1.0);
              endOffset = endOffset.clamp(0.0, 1.0);

              // Calculate width of the log segment in pixels based on the total width
              var width = (endOffset - startOffset) * totalWidth * scaleFactor;

              // Ensure segments are visible, even for very short durations
              if (width < minSegmentWidth) width = minSegmentWidth;

              // Clamp the left position and width to stay within the totalWidth
              final leftPosition = (startOffset * totalWidth).clamp(0.0, totalWidth - minSegmentWidth);
              width = (leftPosition + width > totalWidth) ? totalWidth - leftPosition : width;

              return Positioned(
                left: leftPosition, // Position based on the percentage of total duration
                width: width, // Width based on the calculated offset
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: logColor,
                    borderRadius: BorderRadius.circular(5), // Rounded corners
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
