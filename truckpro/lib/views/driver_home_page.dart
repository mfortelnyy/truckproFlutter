import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/utils/driver_api_service.dart';
import 'package:truckpro/views/upload_photos_view.dart';
import '../models/log_entry.dart';

class DriverHomeView extends StatefulWidget {
  final String token;

  DriverHomeView({required this.token});

  late DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  LogEntry? onDutyLog;
  LogEntry? drivingLog;
  LogEntry? offDutyLog;

  @override
  void initState() {
    super.initState();
    _initializeLogEntries();
  }

  Future<void> _initializeLogEntries() async {
    List<LogEntry> activeLogs = await widget.driverApiService.fetchActiveLogs();
  
    setState(() {
      for (var log in activeLogs) {
         if (log.logEntryType == 1) {
          onDutyLog = log;
        } else if (log.logEntryType == 0) {
          drivingLog = log;
        } else if (log.logEntryType == 3) {
          offDutyLog = log;
        }
      }
    });
  }

  void toggleOnDutyLog() {
    setState(() {
      if (onDutyLog == null) {
        widget.driverApiService.createOnDutyLog();
        _initializeLogEntries();
      } else {
        widget.driverApiService.stopOnDutyLog();
        _initializeLogEntries();
      }
    });
  }

  void toggleDrivingLog() {
    setState(() {
      if (drivingLog == null) {
        // Navigate to upload photos screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPhotosScreen(token: widget.token),
          ),
        );
        _initializeLogEntries();
      } else {
        widget.driverApiService.stopDrivingLog();
        _initializeLogEntries();
      }
    });
  }

  void toggleOffDutyLog() {
    setState(() {
      if (offDutyLog == null) {
        widget.driverApiService.createOffDutyLog();
        _initializeLogEntries();
      } else {
        widget.driverApiService.stopOffDutyLog();
        _initializeLogEntries();
      }
    });
  }

  Duration _calculateElapsedTime(LogEntry? logEntry) {
    if (logEntry?.startTime != null) {
      return DateTime.now().difference(logEntry!.startTime!);
    }
    return Duration.zero;
  }

  double _getProgressOnDuty(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry);
    return elapsedTime.inSeconds / 50400; // Normalize to 14 hours of on duty
  }

  double _getProgressDriving(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry);
    return elapsedTime.inSeconds / 39600; // Normalize to 11 hours of driving
  }

  double _getProgressOffDuty(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry);
    return elapsedTime.inSeconds / 36000; // Normalize to 10 hours of rest
  }

  Widget _buildLogButton(String logType, LogEntry? logEntry, Function toggleLog) {
    double progress = logType == 'On Duty'
        ? _getProgressOnDuty(logEntry)
        : logType == 'Driving'
            ? _getProgressDriving(logEntry)
            : _getProgressOffDuty(logEntry);

    String buttonText = logEntry == null ? 'Start $logType' : 'Stop $logType';

    return GestureDetector(
      onTap: () => toggleLog(),
      child: Container(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 1 ? 1 : progress,
              strokeWidth: 8.0,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Center(
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Home')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Create a triangle layout for buttons
            Positioned(
              top: 100,
              left: 100,
              child: _buildLogButton('On Duty', onDutyLog, toggleOnDutyLog),
            ),
            Positioned(
              top: 0,
              right: 50,
              child: _buildLogButton('Driving', drivingLog, toggleDrivingLog),
            ),
            Positioned(
              bottom: 100,
              left: 100,
              child: _buildLogButton('Off Duty', offDutyLog, toggleOffDutyLog),
            ),
          ],
        ),
      ),
    );
  }
}
