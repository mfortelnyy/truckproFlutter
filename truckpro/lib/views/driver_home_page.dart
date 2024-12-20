import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/utils/driver_api_service.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:truckpro/utils/session_manager.dart';
import 'package:truckpro/views/base_home_view.dart';
import 'package:truckpro/views/driver_stats_view.dart';
import 'package:truckpro/views/logs_view_driver.dart';
import 'package:truckpro/views/upload_photos_view.dart';
import '../models/log_entry.dart';
import '../models/userDto.dart';
import 'active_logs_view.dart';
import 'update_password_view.dart';
import 'user_signin_page.dart';

class DriverHomeView extends BaseHomeView {
  final String token;
  @override
  final SessionManager sessionManager;
  @override
  final Function(bool) toggleTheme; 

  DriverHomeView({super.key, required this.token, required this.sessionManager, required this.toggleTheme}) 
  : super(sessionManager: sessionManager, toggleTheme: toggleTheme);

  late DriverApiService driverApiService = DriverApiService(token: token);
  
  
   
  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends BaseHomeViewState<DriverHomeView> {
  LogEntry? onDutyLog;
  LogEntry? drivingLog;
  LogEntry? offDutyLog;
  LogEntry? breakLog;
  bool isLoading = false;
  Timer? _timer;
  @override
  UserDto? user;
  bool onDutyButtonActive = true;
  bool offDutyButtonActive = true;
  bool drivingButtonActive = true;
  bool breakButtonActive = true;
  late String totalOnDuty;
  bool isDarkMode = false;


  

  final StopWatchTimer _onDutyTimer = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _drivingTimer = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _offDutyTimer = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _breakTimer = StopWatchTimer(mode: StopWatchMode.countDown);

  Timer? _notificationTimer;

  List<LogEntry>? _allActiveLogs;

  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkUnapprovedDrivingLog();

    });
      
     _fetchLogEntries();
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      super.checkSession();
      await _fetchLogEntries();
      _buildWeeklyHoursSection();
    });
  }

  Future<void> _checkUnapprovedDrivingLog() async {
  if (drivingLog != null) {
    //log is unapproved
    if (!drivingLog!.isApprovedByManager) {
      //time difference between now and the log start time
      Duration timeDifference = DateTime.now().difference(drivingLog!.startTime);
      
      //notify managers that logIs not approved
      if (timeDifference.inMinutes > 30) {
        //_sendNotificationToManager(drivingLog!);
      }
    }
  }
}
/*
  void _sendNotificationToManager(LogEntry logEntry) async {
  try {
    // Send notification using driverApiService
    String message = await widget.driverApiService.notifyManager(
      'Driving log needs approval. The driving log started at ${logEntry.startTime} has not been approved for over 30 minutes.'
    );
    
    _showSnackBar(context, "Manager notified: $message");
  } catch (e) {
    _showSnackBar(context, "Failed to notify manager: $e");
  }
}

*/
  _checkWeeklyLimits(double hours) async {
    if (hours > 60) { 
       if (!mounted) return;
       if(onDutyLog != null || drivingLog != null)
       {
          try
          {
            var onDutyStopped = "";
            
            if(onDutyLog != null)
            {
               onDutyStopped = await widget.driverApiService.stopOnDutyLog();
            }

            if(onDutyStopped.contains("successfully"))
            {
              _showSnackBar(context, "Driving and On Duty stopped!", Color.fromARGB(209, 244, 148, 23));

              setState(() {
                // Deactivate buttons, stop driivng and on duty, and clear logs except off duty
                onDutyButtonActive = false; 
                drivingButtonActive = false;
                onDutyLog = null;
                drivingLog = null;
              });
              await _fetchLogEntries();
              _showSnackBar(context, "You have exceeded the weekly on-duty hour limit! Driving and On Duty blocked", Color.fromARGB(209, 244, 148, 23));
            }
          }
          catch(e)
          {
            _showSnackBar(context, e.toString(), Color.fromARGB(230, 247, 42, 66));
          }

       }

   
        //_showSnackBar(context, "You have exceeded the weekly on-duty hour limit!", Color.fromARGB(230, 247, 42, 66));
      } else {
        if (!mounted) return;
      
          // Reactivate buttons if within limits
          onDutyButtonActive = true; 
          drivingButtonActive = true; 
        
      }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false; 
    });
  }

  Future<void> _fetchLogEntries() async {
    setState(() {
      isLoading = true;
    });
    
    try
    {
      totalOnDuty = await widget.driverApiService.getTotalOnDutyHoursLastWeek();
      await _checkWeeklyLimits(convertFromTimespan(totalOnDuty));

    }
    catch(e)
    {
      if(!mounted) return;
      //_showSnackBar(context, "Failed to get total on duty hours", Color.fromARGB(230, 247, 42, 66));
    }
    
    // _checkWeeklyLimits(convertFromTimespan(totalOnDuty));

    try
    {
      user ??= await LoginService().getUserById(widget.token);
    }
    catch(e)
    {
        widget.sessionManager.clearSession();
        if(!mounted) return;

        Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
              );
       _showSnackBar(context, "Failed to get user, user is not found!", Color.fromARGB(230, 247, 42, 66));
    }
    super.checkEmailVerification();
    if(convertFromTimespan(totalOnDuty)>60)
    {
      if(!mounted) return;
      showTopSnackBar(context, "Driving Limit Exceeded! \nLimit resets every Monday 12:00 AM");
      onDutyButtonActive = false;
      drivingButtonActive = false;
    }
    if (!mounted) return;
    

    try {
      LogEntry activeLog = await widget.driverApiService.fetchActiveLogs();
      List<LogEntry> activeLogs = [];
      activeLogs.add(activeLog);
      if (!mounted) return;
      setState(() {
        //totalOnDuty = _getTotalOnDutyHoursLastWeek();
        if (activeLogs.isEmpty) {
          _resetAllTimers();
        } else {
          var limits = {
              LogEntryType.OnDuty:  14,
              LogEntryType.Driving: 11,
              LogEntryType.OffDuty: 10,
              LogEntryType.Break: 0,
            };
          
          processActiveLogs(activeLogs,limits);
        }

        _allActiveLogs = activeLogs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        onDutyLog = null;
        drivingLog = null;
        offDutyLog = null;
        breakLog = null;
        _resetAllTimers();
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

  void _resetAllTimers() {
    _drivingTimer.setPresetTime(mSec: 0);
    _onDutyTimer.setPresetTime(mSec: 0);
    _offDutyTimer.setPresetTime(mSec: 0);

    if (_drivingTimer.isRunning) _drivingTimer.onStopTimer();
    if (_onDutyTimer.isRunning) _onDutyTimer.onStopTimer();
    if (_offDutyTimer.isRunning) _offDutyTimer.onStopTimer();
  }

  void _setTimer(StopWatchTimer timer, Duration elapsed, bool stop) {
    timer.onResetTimer();
    timer.clearPresetTime();
    timer.setPresetTime(mSec: elapsed.inMilliseconds);
    if (!timer.isRunning) {
      timer.onStartTimer();
    }
    if (stop) timer.onStopTimer();
  }

  Widget _buildTimerDisplay(StopWatchTimer timer) {
    return StreamBuilder<int>(
      stream: timer.rawTime,
      initialData: 0,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        final hours = (value ~/ 3600000).toString().padLeft(2, '0');
        final minutes = ((value ~/ 60000) % 60).toString().padLeft(2, '0');
        final seconds = ((value ~/ 1000) % 60).toString().padLeft(2, '0');
        final displayTime = '$hours:$minutes:$seconds';

        return Text(
          displayTime,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  Widget _buildLogButton(String logType, LogEntry? logEntry, Function toggleLog, StopWatchTimer timer) {
    double progress = logType == 'On Duty'
        ? _getProgressOnDuty(logEntry)
        : logType == 'Driving'
            ? _getProgressDriving(logEntry)
            : _getProgressOffDuty(logEntry);

    //Duration elapsedTime = _calculateElapsedTime(logEntry, );
    bool isHovered = false;

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
                    Transform.scale(
                      scale: 2,
                      child: CircularProgressIndicator(
                        value: progress > 1 ? 1 : progress,
                        strokeWidth: 8.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isHovered ? Colors.blue : Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildTimerDisplay(timer),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => toggleLog(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: logEntry == null ?  Colors.teal : Colors.red,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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

  Duration _calculateElapsedTime(LogEntry? logEntry, int limitHrs) {
    if (logEntry?.startTime != null) {
      return Duration(hours: limitHrs) - DateTime.now().difference(logEntry!.startTime);
    }
    return Duration.zero;
  }

 
  
  double _getProgressOnDuty(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry, 14);
    return elapsedTime.inSeconds / 50400; // Normalize to 14 hours of on duty
  }

  double _getProgressDriving(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry, 11);
    return elapsedTime.inSeconds / 39600; // Normalize to 11 hours of driving
  }

  double _getProgressOffDuty(LogEntry? logEntry) {
    Duration elapsedTime = _calculateElapsedTime(logEntry, 10);
    return elapsedTime.inSeconds / 36000; // Normalize to 10 hours of rest
  }

  void _showSnackBar(BuildContext context, String message, Color color)
  {
    if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
          ),    
        );
      }

  }
  
  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.red, 
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry into the screen
    overlay.insert(overlayEntry);

    // Remove the overlay after 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }
   
  void toggleOnDutyLog() async {
    if (onDutyLog == null) {
      if (offDutyLog == null) {//&& DateTime.now().difference(offDutyLog!.startTime) > const Duration(hours: 10)) {
        try {
          var message = await widget.driverApiService.createOnDutyLog();
          
          
          if(message.contains("successfully"))
          {
            _showSnackBar(context, message, Color.fromARGB(219, 79, 194, 70));
            _fetchLogEntries();
          }
          else
          {
            _showSnackBar(context, message.split(":").last, Color.fromARGB(230, 247, 42, 66));
          }
        } catch (e) {
          var msg = e.toString();
          print(msg);
          _showSnackBar(context, msg.split(":").last, Color.fromARGB(230, 247, 42, 66));
        }
      }
      else{
        if (!mounted) return;
       
        try {
          var message = await widget.driverApiService.createOnDutyLog();
          
          _fetchLogEntries();
           setState(() {
          _setTimer(_offDutyTimer, Duration.zero, true);
            offDutyLog = null;
          });
          _showSnackBar(context, message,Color.fromARGB(219, 79, 194, 70));
        } catch (e) {
          _showSnackBar(context, e.toString(), Color.fromARGB(230, 247, 42, 66));
        }
      }
    } else {
      if (drivingLog == null) {
        var message = await widget.driverApiService.stopOnDutyLog();
        if(message.isNotEmpty)
        {
          if (!mounted) return;
          setState(() {
            _setTimer(_onDutyTimer, Duration.zero, true);
          // _onDutyTimer.onStopTimer();
          // _onDutyTimer.clearPresetTime();
          // _onDutyTimer.setPresetTime(mSec: 0);
          
          ();
          onDutyLog = null;
          });
          _showSnackBar(context, 'On Duty log stopped successfully', Color.fromARGB(219, 79, 194, 70));
          //_fetchLogEntries();
        }
        else 
        {
          _showSnackBar(context, 'On Duty log failed to stop!', Color.fromARGB(230, 247, 42, 66));
          
        }
        
      }
    }
}

  void toggleDrivingLog() async {
    //start log
    if (drivingLog == null) {
      if(offDutyLog != null)
      {
        _showSnackBar(context, "Please Stop Off Duty Log before Driving. \nMake sure you've been Off duty for 10 hours to reset your Daily Driving Limit (11 hours)", Color.fromARGB(255, 250, 140, 44));
        return;
      }
      else if(onDutyLog == null)//breakLog != null)
      {
        _showSnackBar(context, "Please Start On Duty before Driving!", Color.fromARGB(255, 250, 140, 44));
        return;
      }
      
      if (onDutyLog?.childLogEntries == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPhotosScreen(token: widget.token, onPhotoUpload: _fetchLogEntries, resetOffDuty: _resetOffDuty),
          ),
        );

        //_showSnackBar(context, 'Driving log started successfully');
      }
      else
      {
        var message = "";
        try
        {
          List<Map<String, dynamic>> l = [];
          message = await widget.driverApiService.createDrivingLog(l);
          if (!mounted) return;
          setState(() {
            _setTimer(_drivingTimer, Duration.zero, false);
            drivingButtonActive = true;
            });
          _fetchLogEntries();
          if(message.contains("successfully"))
          {
            _showSnackBar(context, message,Color.fromARGB(219, 79, 194, 70) );
          }
        }
        catch(e){
          _showSnackBar(context, message, Color.fromARGB(230, 247, 42, 66));
        }
      }
    }
    //stop log
    else {
      if (onDutyLog != null) {
        try
        {
          var message = await widget.driverApiService.stopDrivingLog();
          if (!mounted) return;
          setState(() {
            _setTimer(_drivingTimer, Duration.zero, true);
            // _drivingTimer.onStopTimer();
            // _drivingTimer.clearPresetTime();
            // _drivingTimer.setPresetTime(mSec: 0);
            
            drivingLog = null;
            });
          _fetchLogEntries();
          _showSnackBar(context, message,Color.fromARGB(219, 79, 194, 70) );
        }
        catch(e){

          _showSnackBar(context, "Failed to stop driving log!", Color.fromARGB(230, 247, 42, 66));
        }
      }
    }
  }
  
  void toggleOffDutyLog() async {
  if (offDutyLog == null) {
    var message = await widget.driverApiService.createOffDutyLog();
    if (!mounted) return;
    setState(() {
            _setTimer(_drivingTimer, Duration.zero, true);
            _setTimer(_onDutyTimer, Duration.zero, true);
            drivingButtonActive = false;
            onDutyButtonActive = false;
            offDutyButtonActive = true;
      
          // _drivingTimer.onStopTimer();
          // _drivingTimer.clearPresetTime();
          // _drivingTimer.setPresetTime(mSec: 0);
          
           drivingLog = null;
           onDutyLog = null;
          });
    _fetchLogEntries();
    _showSnackBar(context, message, Color.fromARGB(219, 79, 194, 70));
  } else {
      try
      {
        await widget.driverApiService.stopOffDutyLog();
        if (!mounted) return;
        setState(() {
          _setTimer(_offDutyTimer, Duration.zero, true);
          if(breakLog!= null) 
          {
            _setTimer(_breakTimer, Duration.zero, true);
            breakLog = null;
          }

          offDutyButtonActive = false;
          offDutyLog = null;
        });
        _fetchLogEntries();
        _showSnackBar(context, 'Off Duty log stopped successfully',Color.fromARGB(219, 79, 194, 70));
      }
      catch(e)
      {
        _showSnackBar(context, 'Off Duty log did not stop!', Color.fromARGB(230, 247, 42, 66));
      }
    }
  }

  void toggleBreakLog(bool sleep) async {
  if (breakLog == null) {
    //create sleep log for off duty
    if(offDutyLog !=  null && sleep)
    {
      var message = await widget.driverApiService.createBreakLog();
      if (!mounted) return;
      setState(() {    
            drivingLog = null;
            onDutyLog = null;
            });
      if(message.contains("successfully"))
      {
        _showSnackBar(context, message, Color.fromARGB(219, 79, 194, 70));
        _fetchLogEntries();

      }
      else  
      {
        _showSnackBar(context, message.split(":").last, Color.fromARGB(230, 247, 42, 66));
      }
    }
    //create break log for on duty
    else if(onDutyLog != null && !sleep) {
      try
      {
          var message = await widget.driverApiService.createBreakLog();
          
          
          if(message.contains("successfully"))
          {
            if(drivingLog != null) 
            {
              var msg = await widget.driverApiService.stopDrivingLog();
              if(msg.contains("successfully"))
              {
                _showSnackBar(context, msg, Color.fromARGB(219, 79, 194, 70));
                if (!mounted) return;
                setState(() {
                  _setTimer(_breakTimer, Duration.zero, true);
                  _drivingTimer.onStopTimer();
                  _drivingTimer.clearPresetTime();
                  _drivingTimer.setPresetTime(mSec: 0);
                  drivingLog = null;
                });
              }
            }
            _fetchLogEntries();

            _showSnackBar(context, message, Color.fromARGB(219, 79, 194, 70));

          }
          else  
          {
            _showSnackBar(context, message.split(":").last, Color.fromARGB(230, 247, 42, 66));
          }
      }
      catch(e)
      {
        _showSnackBar(context, 'Sleep log failed to stop!', Color.fromARGB(230, 247, 42, 66));
      }
    }
  }
  //stop break log 
  else
  {
    try
    {
      var message = await widget.driverApiService.stopBreakLog();
      if (!mounted) return;
      setState(() {
        _setTimer(_breakTimer, Duration.zero, true);
        breakLog = null;
      });
      _fetchLogEntries();
      _showSnackBar(context, message, Color.fromARGB(219, 79, 194, 70));
    }
    catch(e)
    {
      _showSnackBar(context, 'Break log failed to stop!', Color.fromARGB(230, 247, 42, 66));
    }
  }
}

  void processActiveLogs(List<LogEntry> activeLogs, Map<LogEntryType, int> limits) {
  if (activeLogs.isEmpty) return;

  var activeParentLog = activeLogs[0];
  //process the activeParentLog itself
  _processLog(activeParentLog, limits);

  //process child logs
  for (var log in activeParentLog.childLogEntries ?? []) {
    _processLog(log, limits);
  }
}

//creates timers for logs presets with elapsed (preset) time
void _processLog(LogEntry log, Map<LogEntryType, int> limits) {
  var elapsed = _calculateElapsedTime(log, limits[log.logEntryType] ?? 0);

  if (log.logEntryType == LogEntryType.OnDuty && onDutyLog == null) {
    onDutyLog = log;
    if (_onDutyTimer.minuteTime.value > 0) {
      _onDutyTimer.onResetTimer();
    }
    _setTimer(_onDutyTimer, elapsed, false);
  } else if (log.logEntryType == LogEntryType.Driving && drivingLog == null) {
    drivingLog = log;
    _setTimer(_drivingTimer, elapsed, false);
  } else if (log.logEntryType == LogEntryType.OffDuty && offDutyLog == null) {
    offDutyLog = log;
    _setTimer(_offDutyTimer, elapsed, false);
  } else if (log.logEntryType == LogEntryType.Break && breakLog == null) {
    breakLog = log;
    _setTimer(_breakTimer, elapsed, false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar:
            AppBar(
              title: user != null
                  ? Text('Welcome, ${user!.firstName} ${user!.lastName}',  
                    textAlign: TextAlign.right,      
                    style: const TextStyle(                     
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  )
                  : const Text('Driver Home Page'),
                 actions: [
                  IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                      widget.toggleTheme(isDarkMode); 
                    },
                  ),
                  buildSettingsPopupMenu(),
                ],
      
              backgroundColor: const Color.fromARGB(255, 241, 158, 89),
            ),
            drawer: _buildDrawer(context, widget.toggleTheme),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Weekly Report section
                          SizedBox(
                            height: 350, 
                            child: _buildSection(
                              title: 'Weekly Report',
                              child: _buildWeeklyHoursSection(),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Buttons for On Duty and Driving in the same row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: onDutyButtonActive ? _buildLogButton('On Duty', onDutyLog, toggleOnDutyLog, _onDutyTimer) : const SizedBox(height: 10, child: Text(""))
                              ),
                              const SizedBox(width: 10), 
                              Expanded(
                                child: drivingButtonActive ? _buildLogButton('Driving', drivingLog, toggleDrivingLog, _drivingTimer) : const SizedBox(height: 10, child: Text("") ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Off Duty and sleep/break button in its own section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                 child: offDutyButtonActive
                                    ? _buildLogButton(
                                        'Off Duty', 
                                        offDutyLog, 
                                        toggleOffDutyLog, 
                                        _offDutyTimer,
                                      )
                                    : const SizedBox(
                                        height: 10,
                                      ),
                              ),
                              const SizedBox(width: 10), 
                              Expanded(
                                child: 
                                onDutyLog != null || offDutyLog != null 
                                ? breakButtonActive
                                    ? _buildLogButton(
                                        offDutyLog != null ? 'Sleep' : 'Break', 
                                        breakLog, 
                                        () => toggleBreakLog(offDutyLog != null), // Pass true if 'Sleep', false if 'Break'
                                        _breakTimer,
                                      )
                                    : const Text("")
                                  : const Text("")   
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  )
                );
              }

  
  // Method to create each section
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          child, //actual content for each section
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Function(bool) toggleTheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
         DrawerHeader(
            decoration:  const BoxDecoration(
              color:Color.fromARGB(255, 241, 158, 89),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                 "Driver Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user != null ? user!.email : 'Loading...',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 14,
                  ),
                ),
              ]
            ),
          ),
          ListTile(
            leading: Icon(Icons.local_activity_rounded, color:  isDarkMode ? Colors.white : Colors.black),
            title: Text('Active Logs', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black)),
            onTap: () async {
              Navigator.pop(context);
              try
              {
                var log = await widget.driverApiService.fetchActiveLogs();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveLogView(token: widget.token, activeLog: log, userDto: user, driverId: user!.id,),
                  ),
                );
              }
              catch(e)
              {
                _showSnackBar(context, "No Active Logs at this time!", Color.fromARGB(230, 247, 42, 66));
              }
              
            },
          ),
          ListTile(
            leading: Icon(Icons.history_rounded, color:  isDarkMode ? Colors.white : Colors.black),
            title: Text('History of Logs', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              var logs = widget.driverApiService.fetchAllLogs();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsViewDriver(token: widget.token, logsFuture: logs, userDto: user, driverId: user!.id,),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.password_rounded, color:  isDarkMode ? Colors.white : Colors.black),
            title:  Text('Change Password', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePasswordView(token: widget.token, toggleTheme: toggleTheme,),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_rounded, color:  isDarkMode ? Colors.white : Colors.black),
            title: Text('See Statistics', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black )),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverStatsView(driverApiService: widget.driverApiService),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color:  isDarkMode ? Colors.white : Colors.black),
            title: Text('Sign Out', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              widget.sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: toggleTheme ,)),
              );
            },
          ),
        ],  
    )
  );
  }

  Widget _buildWeeklyHoursSection() {
  return FutureBuilder<String>(
    future: _getTotalOnDutyHoursLastWeek(),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data == null) {
        return const Text('No data available');
      } else {
        String totalOnDutyHours = snapshot.data!;
        var timeSpanList = totalOnDutyHours.split(":");

        double hoursSum = 0;


        if (timeSpanList.length == 3) {
          if(!timeSpanList[0].contains('.'))
          { 
            hoursSum = double.parse(timeSpanList[0]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]) / 3600;
                   
          }
          else{
            var listdaysHours = timeSpanList[0].split('.');
            hoursSum = double.parse(listdaysHours[0]) * 24 +
            double.parse(listdaysHours[1]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]).round() / 3600;
          }
        }
         
        _checkWeeklyLimits(hoursSum);

        double progress = hoursSum / 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total On-Duty (from last Monday) for ${user?.firstName}: ${hoursSum.round()} / 60 hrs',
              style: const TextStyle(fontSize: 13, color:Color.fromARGB(255, 74, 82, 81), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 100),
            // wrap in Transform to scale up the progress indicator
            Transform.scale(
              scale: 4, 
              child: CircularProgressIndicator(
                value: progress > 1 ? 1 : progress,
                strokeWidth: 5.5, 
                backgroundColor: const Color.fromARGB(255, 233, 18, 18),
                valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 21, 226, 38)),
              ),
            ),
            Center(
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        );
      }
    },
  );
}

  Future<String> _getTotalOnDutyHoursLastWeek() async {
    try{
    return await widget.driverApiService.getTotalOnDutyHoursLastWeek();
    }catch(e)
    {
      return "";
    }
  }

  double convertFromTimespan(String totalOnDutyHours )
  {
    var timeSpanList = totalOnDutyHours.split(":");

        double hoursSum = 0;


        if (timeSpanList.length == 3) {
          if(!timeSpanList[0].contains('.'))
          { 
            hoursSum = double.parse(timeSpanList[0]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]) / 3600;
                   
          }
          else{
            var listdaysHours = timeSpanList[0].split('.');
            hoursSum = double.parse(listdaysHours[0]) * 24 +
            double.parse(listdaysHours[1]) +
            double.parse(timeSpanList[1]) / 60 +
            double.parse(timeSpanList[2]).round() / 3600;
          }
        }
        return hoursSum;
  }

  Future<void> _resetOffDuty() async {
    setState(() {
      _setTimer(_offDutyTimer, Duration.zero, true);
      offDutyLog = null;
    });
  }

}
