import 'dart:async';

import 'package:flutter/material.dart';
import 'package:truckpro/utils/driver_api_service.dart';
import 'package:truckpro/views/logs_view.dart';
import 'package:truckpro/views/testView.dart';
import 'package:truckpro/views/upload_photos_view.dart';
import '../models/log_entry.dart';
import 'update_password_view.dart';
import 'user_signin_page.dart';

class DriverHomeView extends StatefulWidget {
  final String token;

  DriverHomeView({super.key, required this.token});

  late DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  LogEntry? onDutyLog;
  LogEntry? drivingLog;
  LogEntry? offDutyLog;
  bool isLoading = true;
  Timer? _timer; 

  @override
  void initState() {
    super.initState();
    _fetchLogEntries();

    // init  timer to update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _fetchLogEntries();        
      });
    });
  }

  Future<List<LogEntry>?> _fetchLogEntries() async {
    setState(() {
      isLoading = true;
    });
    try {
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
        isLoading = false;
      });
      return activeLogs;
    } catch (e) {
      setState(() {
        onDutyLog = null;
        drivingLog = null;
        offDutyLog = null;
        isLoading = false;
      });
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message)
  {
    if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message')),
        );
      }

  }
  

  void toggleOnDutyLog() async {
      if (onDutyLog == null) {
        if (offDutyLog == null ){//&& DateTime.now().difference(offDutyLog!.startTime) > const Duration(hours: 10)) {
          try{
              var res = await widget.driverApiService.createOnDutyLog();
              _fetchLogEntries();
              _showSnackBar(context, res.toString());
              

          }
          catch(e)
          {
            _showSnackBar(context, e.toString());

          }
        }
      } else {
        if (drivingLog == null) {
          widget.driverApiService.stopOnDutyLog();
          _fetchLogEntries();
        }
      }
  }

  void toggleDrivingLog() {
    setState(() {
      if (drivingLog == null) {
        if (onDutyLog != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadPhotosScreen(token: widget.token),
            ),
          );
        }
      } else {
        if (onDutyLog != null) {
          widget.driverApiService.stopDrivingLog();
          _fetchLogEntries();
        }
      }
    });
  }

  void toggleOffDutyLog() {
    setState(() {
      if (offDutyLog == null) {
        widget.driverApiService.createOffDutyLog();
        _fetchLogEntries();
      } else {
        widget.driverApiService.stopOffDutyLog();
        _fetchLogEntries();
      }
    });
  }

  Duration _calculateElapsedTime(LogEntry? logEntry) {
    if (logEntry?.startTime != null) {
      return DateTime.now().difference(logEntry!.startTime);
    }
    return Duration.zero;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

   Widget _buildLogButton(String logType, LogEntry? logEntry, Function toggleLog) {
  double progress = logType == 'On Duty'
      ? _getProgressOnDuty(logEntry)
      : logType == 'Driving'
          ? _getProgressDriving(logEntry)
          : _getProgressOffDuty(logEntry);

  Duration elapsedTime = _calculateElapsedTime(logEntry);
  bool isHovered = false; // var to track hover state

  return StatefulBuilder(
    builder: (context, setState) {
      return MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Column(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    strokeWidth: 10.0,
                    backgroundColor: const Color.fromARGB(255, 214, 226, 98),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Center(
                    child: Text(
                      formatDuration(elapsedTime),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => toggleLog(),
              style: ButtonStyle(
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const BorderSide(color: Colors.blue, width: 2);
                    }
                    return const BorderSide(color: Colors.transparent, width: 0);
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                overlayColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.2)),
              ),
              child: Text(
                logEntry == null ? 'Start $logType' : 'Stop $logType',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    },
  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogButton('On Duty', onDutyLog, toggleOnDutyLog),
                  const SizedBox(height: 20),
                  _buildLogButton('Driving', drivingLog, toggleDrivingLog),
                  const SizedBox(height: 20),
                  _buildLogButton('Off Duty', offDutyLog, toggleOffDutyLog),
                ],
              ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 158, 89),
            ),
            child: Text('Driver Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.black),
            title: const Text('Get All Logs', style: TextStyle(color: Colors.black)),
            onTap: () {
              var logs = widget.driverApiService.fetchAllLogs();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsView(token: widget.token, logsFuture: logs, approve: false),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.password_rounded, color: Colors.black),
            title: const Text('Change Password', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePasswordView(token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.password_rounded, color: Colors.black),
            title: const Text('TEST TIMER', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestView(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black),
            title: const Text('Sign Out', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
