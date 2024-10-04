import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import '../models/user.dart';
import '../utils/manager_api_service.dart';
import 'drivers_view.dart';
import 'logs_view.dart';
import 'upload_drivers_file.dart';

class ManagerHomeScreen extends StatefulWidget {
  final String token;

  const ManagerHomeScreen({super.key, required this.token});

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  late ManagerApiService managerService;

  List<User> _drivers = [];
  List<PendingUser> _pendingUsers = [];
  List<User> _registeredUsers = [];
  List<LogEntry> _activeDrivingLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    managerService = ManagerApiService(token: widget.token);

    _fetchManagerData();
  }

  Future<void> _fetchManagerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final drivers = await managerService.getAllDriversByCompany();
      final pendingUsers = await managerService.getNotRegisteredFromPending();
      final registeredUsers = await managerService.getRegisteredFromPending();
      final activeDrivingLogs = await managerService.getAllActiveDrivingLogs();

      setState(() {
        _drivers = drivers;
        _pendingUsers = pendingUsers;
        _registeredUsers = registeredUsers;
        _activeDrivingLogs = activeDrivingLogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _approveDrivingLog(int logEntryId) async {
    try {
      await managerService.approveDrivingLogById(logEntryId);
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

  Future<void> _sendEmailToPendingUsers() async {
    try {
      await managerService.sendEmailToPendingUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emails sent to pending users!')),
      );
      _fetchManagerData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
    if (_drivers.isEmpty) {
      return const Center(child: Text('No drivers found'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          var driver = _drivers[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: ListTile(
              title: Text(driver.firstName, style: const TextStyle(color: Colors.black)),
              subtitle: Text('Driver ID: ${driver.id}', style: TextStyle(color: Colors.grey[600])),
              onTap: () {
                var logs = managerService.getLogsByDriverId(driver.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogsView(logsFuture: logs),
                  ),
                );
              },
            ),
          );
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriversView(driversFuture: managerService.getAllDriversByCompany(), adminService: AdminApiService(), companyName: null,),
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
      ),
    );
  }
}
