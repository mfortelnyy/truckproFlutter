import 'dart:ffi';
import 'dart:core';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:truckpro/utils/driver_api_service.dart';

class DriverStatsView extends StatefulWidget {
  final DriverApiService driverApiService;

  const DriverStatsView({super.key, required this.driverApiService});

  @override
  _DriverStatsViewState createState() => _DriverStatsViewState();
}

class _DriverStatsViewState extends State<DriverStatsView> {
  double? _totalOnDutyHours;
  double? _totalDrivingHours;
  double? _totalOffDutyHours;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDriverStats();
  }

  Future<void> _fetchDriverStats() async {
    try {
      final onDutyHours = await widget.driverApiService.getTotalOnDutyHoursLastWeek();
      final drivingHours = await widget.driverApiService.getTotalDrivingHoursLastWeek();
      final offDutyHours = await widget.driverApiService.getTotalOffDutyHoursLastWeek();

      setState(() {
        _totalOnDutyHours = convertToHours(onDutyHours);
        _totalDrivingHours = convertToHours(drivingHours);
        _totalOffDutyHours = convertToHours(offDutyHours);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading stats: $e';
        _isLoading = false;
      });
    }
  }

  double convertToHours(String timeSpan) {
    var timeSpanList = timeSpan.split(":");
    double hoursSum = 0;

    if (timeSpanList.length == 3) {
      if (!timeSpanList[0].contains('.')) {
        hoursSum = double.parse(timeSpanList[0]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]) / 3600;
      } else {
        var listdaysHours = timeSpanList[0].split('.');
        hoursSum = double.parse(listdaysHours[0]) * 24 +
            double.parse(listdaysHours[1]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]).round() / 3600;
      }
    }
    return hoursSum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Statistics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildPieChart(),
                      const SizedBox(height: 20),
                      _buildBarChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      elevation: 4, // Adds shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Work Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _totalDrivingHours ?? 0,
                      title: 'Driving',
                      color: Colors.blue,
                    ),
                    PieChartSectionData(
                      value: _totalOnDutyHours ?? 0,
                      title: 'On Duty',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: _totalOffDutyHours ?? 0,
                      title: 'Off Duty',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Card(
      elevation: 4, // Adds shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hours Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: _totalDrivingHours ?? 0, color: Colors.red)],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: _totalOnDutyHours ?? 0, color: Colors.yellow)],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(toY: _totalOffDutyHours ?? 0, color: Colors.green)],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Driving');
                            case 1:
                              return const Text('On Duty');
                            case 2:
                              return const Text('Off Duty');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 7),
                          );
                        },
                        interval: 5, // Set an interval to avoid overcrowding
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
