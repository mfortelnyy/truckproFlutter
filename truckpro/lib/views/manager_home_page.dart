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
import 'logs_view.dart';
import 'update_password_view.dart';
import 'upload_drivers_file.dart';

class ManagerHomeScreen extends BaseHomeView {
  final String token;
  final SessionManager sessionManager;
  final Function(bool) toggleTheme;
  

  const ManagerHomeScreen({ required this.token, required this.sessionManager, required this.toggleTheme})
    : super(sessionManager: sessionManager, toggleTheme: toggleTheme);

  

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends BaseHomeViewState<ManagerHomeScreen> with SingleTickerProviderStateMixin {
  final ManagerApiService managerService = ManagerApiService();
  late Future<List<User>> _drivers;
  late Future<List<PendingUser>> _allPendingUsers;
  late Future<List<User>> _allRegisteredUsers;
  late Future<List<PendingUser>> _notRegistered;
  late Future<List<LogEntry>> _activeDrivingLogs;
  bool _isLoading = true;
  String? _errorMessage;
  UserDto? user;
  bool isDarkMode = false;

  // animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;




  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    _fetchManagerData();
  }

  Future<void> _fetchManagerData() async {
    _checkSession();
  
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      user ??= await LoginService().getUserById(widget.token);
      super.checkEmailVerification();
      print(widget.token);
      final drivers = managerService.getAllDriversByCompany(widget.token);
      final pendingUsers = managerService.getAllPendingUsers(widget.token);
      final registeredUsers = managerService.getRegisteredFromPending(widget.token);
      final notRegisteredPendingUsers = managerService.getNotRegisteredFromPending(widget.token);
      final activeDrivingLogs = managerService.getAllActiveDrivingLogs(widget.token);

      setState(() {
        _drivers = drivers;
        _isLoading = false;
        _allPendingUsers = pendingUsers;
        _allRegisteredUsers = registeredUsers;
        _notRegistered = notRegisteredPendingUsers;
        _activeDrivingLogs = activeDrivingLogs;
        
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load data: $e";
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        title: user != null
              ? Text('Welcome, ${user!.firstName} ${user!.lastName}',        
                //spaceSize: 72,
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
          ],
      ),
      drawer: _buildDrawer(context, widget.toggleTheme),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    const SizedBox(height: 15,),
                    const Text('Active Logs', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 25,),
                    _buildActiveLogsList(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogsView(logsFuture: _activeDrivingLogs, token: widget.token, approve: true, onApprove: _fetchManagerData,),
                          ),
                        );
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
                    title: Text(
                      log.logEntryType.toString().split(".").last,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      
                    ),
                    subtitle:log.endTime != null
                      ? Text(
                        'Driver: ${log.user!.firstName} ${log.user!.lastName} \n ${formatDateTime(log.startTime)} - ${formatDateTime(log.endTime!)}',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                      : Text(
                        'Driver: ${log.user!.firstName} ${log.user!.lastName} \nStart Time: ${formatDateTime(log.startTime)}\nIn Progress',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    trailing: log.logEntryType == LogEntryType.Driving && !log.isApprovedByManager
                      ? IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          onPressed: () {
                          },
                        ),
                    onTap: log.logEntryType == LogEntryType.Driving
                    ? () async {
                      //var imageUrls = await managerService.getImagesOfDrivingLog(log.id, widget.token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerApproveView(imageUrls: Future.value(log.imageUrls), log: log, token: widget.token, onApprove: _fetchManagerData,),
                        ),
                      );
                    }
                    : () async {
                      
                    }
                  ),
                );
              },
            );
          }
        },
      ),
    );
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
                  builder: (context) => UpdatePasswordView(token: widget.token),
                  ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: Text('Get All Pending Users', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _allPendingUsers, token: widget.token, sendEmail: true, onEmailsSent: _fetchManagerData,),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Colors.black),
            title: Text('All Registered Users from Pending', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriversViewManager(driversFuture: _allRegisteredUsers, token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: Text('Not Registered Pending Users', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _notRegistered, token: widget.token, sendEmail: true,)
                ),
              );
            },
          ),
          /*
          ListTile(
            leading: const Icon(Icons.local_activity_rounded, color: Colors.black),
            title: const Text('All Dri Logs', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsView(logsFuture: _activeDrivingLogs, token: widget.token, approve: true, onApprove: _fetchManagerData,)
                ),
              );
            },
          ),*/
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
}
