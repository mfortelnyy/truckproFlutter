import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/utils/driver_api_service.dart';
import '../models/log_entry.dart';

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
  bool isLoading = false;
  Timer? _timer;

  // Store elapsed times
  int onDutyElapsedTime = 0;
  int drivingElapsedTime = 0;
  int offDutyElapsedTime = 0;

  StopWatchTimer _onDutyTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  StopWatchTimer _drivingTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  StopWatchTimer _offDutyTimer = StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
    _fetchLogEntries();

    // init timer to update every 30 minutes
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _fetchLogEntries();
    });
  }

  Future<void> _fetchLogEntries() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      List<LogEntry> activeLogs = await widget.driverApiService.fetchActiveLogs();

      // Clear logs at the beginning
      onDutyLog = null;
      drivingLog = null;
      offDutyLog = null;

      if (activeLogs.isEmpty) {
        // Stop and reset timers
        if (_drivingTimer.isRunning) {
          _drivingTimer.onStopTimer();
          drivingElapsedTime = 0; // reset elapsed time
        }
        if (_onDutyTimer.isRunning) {
          _onDutyTimer.onStopTimer();
          onDutyElapsedTime = 0; // reset elapsed time
        }
        if (_offDutyTimer.isRunning) {
          _offDutyTimer.onStopTimer();
          offDutyElapsedTime = 0; // reset elapsed time
        }
      } else {
        // Start the timers based on active logs
        for (var log in activeLogs) {
          var elapsed = _calculateElapsedTime(log);
          if (log.logEntryType == LogEntryType.OnDuty.index) {
            onDutyLog = log;
            onDutyElapsedTime = elapsed.inMilliseconds; // Save elapsed time
            _onDutyTimer.setPresetTime(mSec: onDutyElapsedTime);
            if (!_onDutyTimer.isRunning) {
              _onDutyTimer.onStartTimer();
            }
          } else if (log.logEntryType == LogEntryType.Driving.index) {
            drivingLog = log;
            drivingElapsedTime = elapsed.inMilliseconds; // Save elapsed time
            _drivingTimer.setPresetTime(mSec: drivingElapsedTime);
            if (!_drivingTimer.isRunning) {
              _drivingTimer.onStartTimer();
            }
          } else if (log.logEntryType == LogEntryType.OffDuty.index) {
            offDutyLog = log;
            offDutyElapsedTime = elapsed.inMilliseconds; // Save elapsed time
            _offDutyTimer.setPresetTime(mSec: offDutyElapsedTime);
            if (!_offDutyTimer.isRunning) {
              _offDutyTimer.onStartTimer();
            }
          }
        }
      }

      // Update the active logs state
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        onDutyLog = null;
        drivingLog = null;
        offDutyLog = null;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _onDutyTimer.dispose();
    _drivingTimer.dispose();
    _offDutyTimer.dispose();
    super.dispose();
  }

  Duration _calculateElapsedTime(LogEntry? logEntry) {
    if (logEntry?.startTime != null) {
      return DateTime.now().difference(logEntry!.startTime);
    }
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLogEntries,
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Add your timer display widgets here
                ],
              ),
      ),
    );
  }
}
