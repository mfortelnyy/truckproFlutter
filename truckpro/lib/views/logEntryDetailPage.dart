import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/views/drvinglog_images_view.dart';
import 'package:truckpro/views/log_bar_chart.dart';

class LogEntryDetailPage extends StatelessWidget {
  final LogEntry parentLog;
  final List<LogEntry>? childrenLogs;
  final String token;
  final bool? approve;
  final void Function()? onApprove;

  const LogEntryDetailPage({
    Key? key,
    required this.parentLog,
    required this.childrenLogs,
    required this.token,
    this.approve,
    this.onApprove,
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
        title: const Text('Log Entry Overview', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Parent Log Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 8, 
              color: isDarkTheme ? const Color.fromARGB(255, 15, 13, 13) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_formatLogEntryType(parentLog.logEntryType.toString().split(".").last)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                    if (childrenLogs != null && childrenLogs!.isNotEmpty)
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LogBarChart(
                            logEntries: childrenLogs!,
                            logColors: logColors,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Events Legend
            Text(
              'Events',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            // Child Log Timeline with Divider
            ListView.builder(
              shrinkWrap: true, 
              itemCount: childrenLogs?.length ?? 0,
              itemBuilder: (context, index) {
                final log = childrenLogs![index];
                return Column(
                  children: [
                    _buildTimelineItem(context, log),
                    if (index < (childrenLogs?.length ?? 0) - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 3, 
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(DateTime? dateTime, {String prefix = ''}) {
    if (dateTime != null) {
      return "$prefix ${DateFormat('MMM dd, yyyy, hh:mm a').format(dateTime)}";
    } else {
      return 'In progress';
    }
  }


  //adds a space before uppercase letters (format LogEntry type)
  String _formatLogEntryType(String type) {
    return type.replaceAllMapped(RegExp(r'(?<!^)([A-Z])'), (match) => ' ${match.group(0)}');
  }

  //TimelineItem for each child log
  Widget _buildTimelineItem(BuildContext context, LogEntry log) {
    IconData icon;
    Color color;
    String imageText = '';
    bool hasImages = false;
    bool isApproved = approve ?? false;

    if (log.logEntryType == LogEntryType.Driving) {
      if (log.imageUrls != null && log.imageUrls!.isNotEmpty) {
        imageText = '${log.imageUrls!.length} images';
        hasImages = true;
      } else {
        imageText = 'No images';
      }
      if (log.isApprovedByManager) {
        imageText += ' (Approved)';
      }
    }

    switch (log.logEntryType) {
      case LogEntryType.Break:
        icon = Icons.pause;
        color = Colors.yellow[600]!; // Break color
        break;
      case LogEntryType.Driving:
        icon = Icons.drive_eta;
        color = Colors.green[400]!; // Driving color
        break;
      case LogEntryType.OnDuty:
        icon = Icons.access_alarm;
        color = Colors.orange[400]!; // On Duty color
        break;
      case LogEntryType.OffDuty:
        icon = Icons.ac_unit_outlined;
        color = Colors.blue[400]!; // Parent/Off Duty color
        break;
      default:
        icon = Icons.help;
        color = Colors.grey[400]!; // Default color
    }

    return GestureDetector(
      onTap: hasImages
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrivingLogImagesView(
                    imageUrls: Future.value(log.imageUrls ?? []),
                    log: log,
                    token: token,
                    onApprove: isApproved ? null : onApprove,
                  ),
                ),
              );
            }
          : null,
      child: TimelineTile(
        alignment: TimelineAlign.manual,
        lineXY: 0.65,
        isFirst: log == childrenLogs?.first,
        isLast: log == childrenLogs?.last,
        beforeLineStyle: LineStyle(color: color, thickness: 4),
        indicatorStyle: IndicatorStyle(
          color: color,
          width: 32,
          iconStyle: IconStyle(
            iconData: icon,
            color: Colors.white,
          ),
        ),
        startChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateCard(formatDateTime(log.startTime), Icons.arrow_upward, color),
              const SizedBox(height: 8),
              _buildDateCard(formatDateTime(log.endTime), Icons.arrow_downward, color),
            ],
          ),
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatLogEntryType(log.logEntryType.toString().split(".").last),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (log.logEntryType == LogEntryType.Driving)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    imageText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(String dateText, IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.6), 
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(2, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), 
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16, 
          color: Colors.white, 
        ),
        const SizedBox(width: 6), 
        Text(
          dateText,
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.bold,
            //color:  context.isDarkTheme ? Colors.white : Colors.black, // Use contrasting text color
          ),
        ),
      ],
    ),
  );
}
  
}
