import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/utils/driver_api_service.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:truckpro/utils/session_manager.dart';
import 'package:truckpro/views/driver_stats_view.dart';
import 'package:truckpro/views/logs_view.dart';
import 'package:truckpro/views/upload_photos_view.dart';
import '../models/log_entry.dart';
import '../models/userDto.dart';
import 'update_password_view.dart';
import 'user_signin_page.dart';

class DriverHomeView extends StatefulWidget {
  final String token;
  final SessionManager sessionManager;
  final Function(bool) toggleTheme; 

  DriverHomeView({super.key, required this.token, required this.sessionManager, required this.toggleTheme});

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
  UserDto? user;
  bool onDutyButtonActive = true;
  bool offDutyButtonActive = true;
  bool drivingButtonActive = true;
  late String totalOnDuty;
  bool isDarkMode = false;


  

  final StopWatchTimer _onDutyTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  final StopWatchTimer _drivingTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  final StopWatchTimer _offDutyTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  Timer? _notificationTimer;

  List<LogEntry>? _allActiveLogs;

  
  @override
  void initState() {
    super.initState();
   
    // _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
    //   _checkUnapprovedDrivingLog();
    // });
      
    _fetchLogEntries();
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _fetchLogEntries();
      _buildWeeklyHoursSection();
    });
  }
/*
  Future<void> _checkUnapprovedDrivingLog() async {
  if (drivingLog != null) {
    //log is unapproved
    if (!drivingLog!.isApprovedByManager) {
      //time difference between now and the log start time
      Duration timeDifference = DateTime.now().difference(drivingLog!.startTime);
      
      //notify managers that logIs not approved
      if (timeDifference.inMinutes > 30) {
        _sendNotificationToManager(drivingLog!);
      }
    }
  }
}

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
  _checkWeeklyLimits(double hours){
    if (hours > 60) { 
       if (!mounted) return;
        
          // Deactivate buttons except off duty
          onDutyButtonActive = false; 
          drivingButtonActive = false;
   
        _showSnackBar(context, "You have exceeded the weekly on-duty hour limit!");
      } else {
        if (!mounted) return;
      
          // Reactivate buttons if within limits
          onDutyButtonActive = true; 
          drivingButtonActive = true; 
        
      }
  }

  Future<void> _fetchLogEntries() async {
    _checkSession();
    
    totalOnDuty = await widget.driverApiService.getTotalOnDutyHoursLastWeek();
    user ??= await LoginService().getUserById(widget.token);
    _checkEmailVerification();
    if(convertFromTimespan(totalOnDuty)>60)
    {
      showTopSnackBar(context, "Driving Limit Exceeded! \nLimit resets every Monday 12:00 AM");
      onDutyButtonActive = false;
      drivingButtonActive = false;
    }
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      List<LogEntry> activeLogs = await widget.driverApiService.fetchActiveLogs();
      if (!mounted) return;
      setState(() {
        //totalOnDuty = _getTotalOnDutyHoursLastWeek();
        if (activeLogs.isEmpty) {
          _resetAllTimers();
        } else {
          for (var log in activeLogs) {
            var elapsed = _calculateElapsedTime(log);

            if (log.logEntryType == LogEntryType.OnDuty.index && onDutyLog == null) {
              onDutyLog = log;
              if (_onDutyTimer.minuteTime.value > 0) {
                _onDutyTimer.onResetTimer();
              }
              _setTimer(_onDutyTimer, elapsed, false);
            } else if (log.logEntryType == LogEntryType.Driving.index && drivingLog == null) {
              drivingLog = log;
              _setTimer(_drivingTimer, elapsed, false);
            } else if (log.logEntryType == LogEntryType.OffDuty.index && offDutyLog == null) {
              offDutyLog = log;
              _setTimer(_offDutyTimer, elapsed, false);
            }
          }
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
        _resetAllTimers();
        isLoading = false;
      });
    }
  }

  Future<void> _checkSession() async {
    //clears token is expired
    await widget.sessionManager.autoSignOut();
    final token = await widget.sessionManager.getToken();
    
    //if token was expired then it's null
    if (token == null) {
      widget.sessionManager.clearSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme,)),
      );
    }
  }

  Future<void> _checkEmailVerification() async {
    try {
      print(user!.emailVerified);
      if (user != null && !user!.emailVerified) {
        _showVerificationDialog();  // Show the dialog to enter verification code
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,  
      builder: (BuildContext context) {
        TextEditingController _verificationCodeController = TextEditingController();
        return AlertDialog(
          title: const Text('Email Verification Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Please enter the verification code sent to your email:'),
              const SizedBox(height: 16),
              TextField(
                controller: _verificationCodeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String verificationCode = _verificationCodeController.text.trim();
                String res = await LoginService().verifyEmail(widget.token, verificationCode); 
                if(res.isEmpty)
                {
                  _showSnackBar(context, "Can not verify email!");
                  Navigator.of(context).pop();
                  
                } 
                 _showSnackBar(context, "Email verified! successfully");
                 
                  Navigator.of(context).pop();


              },
              child: const Text('Verify'),
            ),
            TextButton(
              onPressed: () async {
                var res = await LoginService().reSendEmailCode(widget.token, user!.email);
                if (res.isNotEmpty)
                {
                  _showSnackBar(context, res);
                }
                else 
                {
                   _showSnackBar(context, "Email can not be sent!");
                }
              },
              child: Text('Resend Code to ${user!.email}'),
            ),
          ],
        );
      },
    );
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

    Duration elapsedTime = _calculateElapsedTime(logEntry);
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
                  foregroundColor: Colors.white, backgroundColor: logEntry == null ? Colors.teal : Colors.red,
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

  Duration _calculateElapsedTime(LogEntry? logEntry) {
    if (logEntry?.startTime != null) {
      return DateTime.now().difference(logEntry!.startTime);
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

  void _showSnackBar(BuildContext context, String message)
  {
    if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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
            padding: EdgeInsets.all(20),
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
    overlay?.insert(overlayEntry);

    // Remove the overlay after 3 seconds
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }
   
  void toggleOnDutyLog() async {
    if (onDutyLog == null) {
      if (offDutyLog == null) {//&& DateTime.now().difference(offDutyLog!.startTime) > const Duration(hours: 10)) {
        try {
          var message = await widget.driverApiService.createOnDutyLog();
          
          _fetchLogEntries();
          _showSnackBar(context, message);
        } catch (e) {
          _showSnackBar(context, e.toString());
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
          _showSnackBar(context, message);
        } catch (e) {
          _showSnackBar(context, e.toString());
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
          _showSnackBar(context, 'On Duty log stopped successfully');
          //_fetchLogEntries();
        }
        else 
        {
          _showSnackBar(context, 'On Duty log did not stop!');
          
        }
        
      }
    }
}

  void toggleDrivingLog() async {
    if (drivingLog == null) {
      
      //if (onDutyLog != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPhotosScreen(token: widget.token, onPhotoUpload: _fetchLogEntries, resetOffDuty: _resetOffDuty),
          ),
        );

        //_showSnackBar(context, 'Driving log started successfully');
      //}
    } else {
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
          _showSnackBar(context, message);
        }
        catch(e){

          _showSnackBar(context, "Failed to stop driving log!");
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
      
          // _drivingTimer.onStopTimer();
          // _drivingTimer.clearPresetTime();
          // _drivingTimer.setPresetTime(mSec: 0);
          
           drivingLog = null;
           onDutyLog = null;
          });
    _fetchLogEntries();
    _showSnackBar(context, message);
  } else {
      try
      {
        await widget.driverApiService.stopOffDutyLog();
        if (!mounted) return;
        setState(() {
          _setTimer(_offDutyTimer, Duration.zero, true);
          // _offDutyTimer.onStopTimer();
          // _offDutyTimer.clearPresetTime();
          // _offDutyTimer.setPresetTime(mSec: 0);
          offDutyLog = null;
        });
        _fetchLogEntries();
        _showSnackBar(context, 'Off Duty log stopped successfully');
      }
      catch(e)
      {
        _showSnackBar(context, 'Off Duty log did not stop!');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar:
            AppBar(
              title: user != null
                  ? Text('Welcome, ${user!.firstName} ${user!.lastName}',        
                    //spaceSize: 72,
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
                                child:onDutyButtonActive ? _buildLogButton('On Duty', onDutyLog, toggleOnDutyLog, _onDutyTimer) : const Center(child: SizedBox(height:  100, child: Text("Weekly On Duty Limit exceeded!") )),
                              ),
                              const SizedBox(width: 10), 
                              Expanded(
                                child: drivingButtonActive? _buildLogButton('Driving', drivingLog, toggleDrivingLog, _drivingTimer) : const SizedBox(height: 100, child: Text("") ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Off Duty button in its own section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: offDutyButtonActive ? _buildLogButton('Off Duty', offDutyLog, toggleOffDutyLog, _offDutyTimer) : const SizedBox(height: 100, child: Text("Weekly On Duty Limit exceeded!") )
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
              color:  isDarkMode ? Colors.white : Colors.black,
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
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ]
            ),
          ),
          ListTile(
            leading: Icon(Icons.local_activity_rounded, color:  isDarkMode ? Colors.white : Colors.black),
            title: Text('Active Logs', style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              var logs = widget.driverApiService.fetchActiveLogs();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsView(token: widget.token, logsFuture: logs, approve: false, userDto: user),
                ),
              );
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
                  builder: (context) => LogsView(token: widget.token, logsFuture: logs, approve: false, userDto: user,),
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
                  builder: (context) => UpdatePasswordView(token: widget.token),
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
              // Navigator.pop(context);
              // Navigator.pop(context);

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
         
       // _checkWeeklyLimits(hoursSum);

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
