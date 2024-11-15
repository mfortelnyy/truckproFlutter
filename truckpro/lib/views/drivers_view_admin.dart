import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import '../utils/admin_api_service.dart';
import 'logs_view_manager.dart';

class DriversViewAdmin extends StatefulWidget {
  final AdminApiService adminService;
  final Future<List<User>> driversFuture;
  final String? companyName;
  final String token;

  const DriversViewAdmin({
    super.key,
    required this.adminService,
    required this.driversFuture,
    required this.companyName,
    required this.token,
  });

  @override
  _DriversViewAdminState createState() => _DriversViewAdminState();
}

class _DriversViewAdminState extends State<DriversViewAdmin> {
  List<User> allDrivers = [];
  List<User> filteredDrivers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.driversFuture.then((drivers) {
      setState(() {
        allDrivers = drivers;
        filteredDrivers = drivers;
      });
    });
  }

  void _filterDrivers(String query) {
    final filtered = allDrivers.where((driver) {
      final fullName = '${driver.firstName} ${driver.lastName}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchQuery = query;
      filteredDrivers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterDrivers,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: widget.driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No drivers found for company: ${widget.companyName}'));
          } else {
            return ListView.builder(
              itemCount: filteredDrivers.length,
              itemBuilder: (context, index) {
                var driver = filteredDrivers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    title: Text('${driver.firstName} ${driver.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${driver.email}'),
                        Text('Phone: ${driver.phone}'),
                        Text('Role: ${roleToString(driver.role)}'),
                        Text('Email Verified: ${driver.emailVerified ? "Yes" : "No"}'),
                      ],
                    ),
                    onTap: () async {
                      var logs = widget.adminService.getLogsByDriverId(driver.id, widget.token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsViewManager(
                            logsFuture: logs,
                            token: widget.token,
                            approve: false,
                            driverId: driver.id,
                          ),
                        ),
                      );
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

String roleToString(int role) {
  switch (role) {
    case 0:
      return "Admin";
    case 1:
      return "Manager";
    case 2:
      return "Driver";
    default:
      return "default";
  }
}
