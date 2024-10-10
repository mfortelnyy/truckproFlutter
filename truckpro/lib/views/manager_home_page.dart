import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import 'package:truckpro/views/pending_users_view.dart';
import 'package:truckpro/views/user_signin_page.dart';
import '../models/log_entry.dart';
import '../models/user.dart';
import '../utils/manager_api_service.dart';
import 'drivers_view_manager.dart';
import 'logs_view.dart';
import 'update_password_view.dart';
import 'upload_drivers_file.dart';

class ManagerHomeScreen extends StatefulWidget {
  final String token;

  const ManagerHomeScreen({super.key, required this.token});
  

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final ManagerApiService managerService = ManagerApiService();
  late Future<List<User>> _drivers;
  late Future<List<PendingUser>> _allPendingUsers;
  late Future<List<User>> _allRegisteredUsers;
  late Future<List<PendingUser>> _notRegistered;
  late Future<List<LogEntry>> _activeDrivingLogs;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    

    _fetchManagerData();
  }

  Future<void> _fetchManagerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

  Future<void> _approveDrivingLog(int logEntryId, String token) async {
    try {
      await managerService.approveDrivingLogById(logEntryId, token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driving Log approved!')),
      );
      _fetchManagerData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _sendEmailToPendingUsers(String token) async {
    try {
      await managerService.sendEmailToPendingUsers(token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emails sent to pending users!')),
      );
      _fetchManagerData(); 
    } catch (e) {
      if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchManagerData,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    const Text('Drivers List', style: TextStyle(fontSize: 20)),
                    _buildDriversList(),
                  ],
                ),
    );
  }

  Widget _buildDriversList() {
  return Expanded(  
    child: FutureBuilder<List<User>>(
      future: _drivers,  
            builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No drivers found'));
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var driver = snapshot.data![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(driver.firstName, style: const TextStyle(color: Colors.black)),
                        subtitle: Text('Driver ID: ${driver.id}', style: TextStyle(color: Colors.grey[600])),
                        onTap: () {
                          var logs = managerService.getLogsByDriverId(driver.id, widget.token);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogsView(logsFuture: logs, token: widget.token,),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriversViewManager(driversFuture: Future.value(snapshot.data!), companyName: null, token: widget.token,),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 158, 89), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Show All Drivers', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      },
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
            child: Text('Manager Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.black),
            title: const Text('Upload Driver Emails (.xlsx upload)', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadDriversScreen(managerApiService: managerService, token: widget.token),
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
                //UploadDriversScreen(managerApiService: managerService, token: widget.token), 
                  ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: const Text('Get All Pending Users', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _allPendingUsers, token: widget.token, sendEmail: false,),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Colors.black),
            title: const Text('All Registered Users from Pending', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriversViewManager(driversFuture: _allRegisteredUsers, token: widget.token, companyName: null,),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_rounded, color: Colors.black),
            title: const Text('Not Registered Pending Users', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingUsersView(pendingUsersFuture: _notRegistered, token: widget.token, sendEmail: true,)
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_activity_rounded, color: Colors.black),
            title: const Text('All Active Logs', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsView(logsFuture: _activeDrivingLogs, token: widget.token, )
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
                MaterialPageRoute(
                  builder: (context) => const SignInPage()
                ),
              );
            },
          ),
          
        ],
      ),
    );
  }
}
