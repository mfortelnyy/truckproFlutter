import 'package:flutter/material.dart';

import '../utils/adminApiService.dart';

class AdminHomePage extends StatefulWidget {
  final AdminApiService adminService;
  final String token;

  const AdminHomePage({required this.adminService, required this.token});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  
  late Future<List<dynamic>> _companies;
  late Future<List<dynamic>> _drivers;

  @override
  void initState() {
    super.initState();
    _companies = widget.adminService.getAllCompanies(widget.token);
    _drivers = widget.adminService.getAllDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _companies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No companies found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var company = snapshot.data![index];
                      return ListTile(
                        title: Text(company['name']), 
                        subtitle: Text('ID: ${company['id']}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _drivers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No drivers found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var driver = snapshot.data![index];
                      return ListTile(
                        title: Text(driver['name']),
                        subtitle: Text('Driver ID: ${driver['id']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverLogsView(driverId: driver['id'], adminService: widget.adminService),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  DriverLogsView({required driverId, required AdminApiService adminService}) {}
}
 
