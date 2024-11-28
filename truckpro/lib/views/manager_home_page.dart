import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:truckpro/utils/session_manager.dart';
import 'package:truckpro/views/base_home_view.dart';
import 'package:truckpro/views/manager_approve_view.dart';
import 'package:truckpro/views/pending_users_view.dart';
import 'package:truckpro/views/user_signin_page.dart';
import '../models/log_entry.dart';
import '../models/user.dart';
import '../models/userDto.dart';
import '../utils/manager_api_service.dart';
import 'drivers_view_manager.dart';
import 'logs_view_manager.dart';
import 'update_password_view.dart';
import 'upload_drivers_file.dart';

class ManagerHomeScreen extends BaseHomeView {
  final String token;
  @override
  final SessionManager sessionManager;
  @override
  final Function(bool) toggleTheme;
  

  const ManagerHomeScreen({super.key,  required this.token, required this.sessionManager, required this.toggleTheme})
    : super(sessionManager: sessionManager, toggleTheme: toggleTheme);

  

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends BaseHomeViewState<ManagerHomeScreen> with SingleTickerProviderStateMixin {
  final ManagerApiService managerService = ManagerApiService();
  Future<List<User>>? _drivers;
  Future<List<PendingUser>>? _allPendingUsers; 
  Future<List<User>>? _allRegisteredUsers;
  Future<List<PendingUser>>? _notRegistered;
  Future<List<LogEntry>>? _activeDrivingLogs;
  bool _isLoading = false;
  String? _errorMessage;
  @override
  UserDto? user;
  bool isDarkMode = false;

  // animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  @override
void initState() {
  super.initState();
  _loadSettings();
  _fetchManagerData(); 
  
  //animation init
  _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  _fadeInAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  _animationController.forward();
}

Future<void> _fetchManagerData() async {
  super.checkSession();

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    user ??= await LoginService().getUserById(widget.token);

    _drivers = managerService.getAllDriversByCompany(widget.token);
    _allPendingUsers = managerService.getAllPendingUsers(widget.token);
    _allRegisteredUsers = managerService.getRegisteredFromPending(widget.token);
    _notRegistered = managerService.getNotRegisteredFromPending(widget.token);
    _activeDrivingLogs = managerService.getAllActiveDrivingLogs(widget.token);
    
    super.checkEmailVerification();
    
    setState(() {
      _isLoading = false;
      _errorMessage = null;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString().split(': ').last;
      _isLoading = false;
    });
  }
}

   String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    return formatter.format(dateTime);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false; 
    });
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

  Widget _buildDrawer(BuildContext context, Function(bool) toggleTheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
           DrawerHeader(
            decoration: const BoxDecoration(
              color:  Color.fromARGB(255, 241, 158, 89),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const Text(
                 "Manager Menu",
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
            ),),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.black),
            title: Text('Upload Driver Emails (.xlsx upload)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadDriversScreen(managerApiService: managerService, token: widget.token, onUpload: _fetchManagerData,),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.password_rounded, color: Colors.black),
            title: Text('Change Password', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: Text('All Drivers in the Company', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriversViewManager(driversFuture: _drivers!, token: widget.token),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: Text('All Pending Drivers', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _allPendingUsers!, token: widget.token, sendEmail: false ),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Colors.black),
            title: Text('All Registered Users from Pending', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              if(_allRegisteredUsers!=null)
              {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriversViewManager(driversFuture: _allRegisteredUsers!, token: widget.token),
                  ),
                );
              }
              else{
                _showSnackBar(context, "No Registered Users at this time!");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: Text('Not Registered Pending Users', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _notRegistered!, token: widget.token, sendEmail: true,)
                ),
              );
            },
          ),
          const Divider(), 
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black),
            title: Text('Sign Out', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              widget.sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInPage(toggleTheme: toggleTheme,)
                ),
              );
            },
          ),
          
        ],
      ),
    );
  }



  
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      title: user != null
          ? Text(
              'Welcome, ${user!.firstName} ${user!.lastName}',
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            )
          : const Text('Manager Home'),
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
        buildSettingsPopupMenu()
      ],
    ),
    drawer: _buildDrawer(context, widget.toggleTheme),
    body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const SizedBox(height: 15,),
              const Text('Active Logs', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 25,),
              _buildActiveLogsList(),
              ElevatedButton(
                onPressed: () {
                  if (_activeDrivingLogs != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogsViewManager(
                          logsFuture: _activeDrivingLogs!,
                          token: widget.token,
                          approve: true,
                          onApprove: _fetchManagerData,
                          driverId: 0,
                        ),
                      ),
                    );
                  } else {
                    _showSnackBar(context, "No drivers are active at the moment!");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 158, 89),
                ),
                child: const Text('Show All Active', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20,)
            ]
        ),
  );
}

  Widget _buildActiveLogsList() {
    return Expanded(
      child: FutureBuilder<List<LogEntry>>(
        future: _activeDrivingLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active logs found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var log = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                          log.logEntryType == LogEntryType.Driving
                              ? Icons.directions_car
                              : Icons.description,
                          color: log.logEntryType == LogEntryType.Driving
                              ? Colors.blue
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          log.logEntryType.toString().split(".").last,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (log.logEntryType == LogEntryType.Driving && !log.isApprovedByManager) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning, color: Colors.red, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Needs Approval',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: log.endTime != null
                          ? Text(
                              'Driver: ${log.user!.firstName} ${log.user!.lastName}\n'
                              '${formatDateTime(log.startTime)} - ${formatDateTime(log.endTime!)}',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          : Text(
                              'Driver: ${log.user!.firstName} ${log.user!.lastName}\n'
                              'Start Time: ${formatDateTime(log.startTime)}\nIn Progress',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                    ),
                    trailing: PopupMenuButton<int>(
                      icon: Icon(
                        log.logEntryType == LogEntryType.Driving 
                          ? !log.isApprovedByManager
                              ? Icons.error
                              : Icons.check
                          : null,
                        color: 
                          log.logEntryType == LogEntryType.Driving  
                            ? !log.isApprovedByManager
                                ? Colors.red
                                : Colors.green
                            :  Colors.white
                      ),
                      onSelected: (value) {
                        
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Text(
                            log.logEntryType == LogEntryType.Driving
                                ? 'Approve Driving'
                                : 'View Log',
                          ),
                        ),
                      ],
                    ),
                    onTap: log.logEntryType == LogEntryType.Driving
                        ? () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManagerApproveView(
                                  imageUrls: Future.value(log.imageUrls),
                                  log: log,
                                  token: widget.token,
                                  onApprove: _fetchManagerData,
                                ),
                              ),
                            );
                          }
                        : () {
                          },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
