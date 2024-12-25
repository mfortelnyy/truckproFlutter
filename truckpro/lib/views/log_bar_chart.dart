import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:truckpro/models/log_entry.dart';

class LogBarChart extends StatelessWidget {
  final List<LogEntry> logEntries;  // List of log entries (both parent and children)
  final Map<String, Color> logColors;  // Map of log entry types to colors

  LogBarChart({
    required this.logEntries,
    required this.logColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          alignment: BarChartAlignment.center,
          barGroups: _buildBarGroups(),
          maxY: 1,  // We are working with a single row, so maxY is always 1
          minY: 0,
        ),
      ),
    );
  }

  // Build the bar groups
  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];
    double startX = 0;

    for (var log in logEntries) {
      Color color = logColors[log.logEntryType.toString()] ?? Colors.grey;
      double duration = log.endTime!.difference(log.startTime!).inMinutes.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: 0, // Only one bar is needed since it is a horizontal chart
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: 1,  // Full height for each log segment
              color: color,
              width: duration,  // Width based on log duration (in minutes)
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }
}
