import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';
import '../models/user.dart';
import '../utils/admin_api_service.dart';
import 'companies_view.dart'; 
import 'drivers_view.dart';
import 'logs_view.dart'; 

class AdminHomePage extends StatefulWidget {
  final AdminApiService adminService;
  final String token;

  const AdminHomePage({super.key, required this.adminService, required this.token});

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  
  late Future<List<Company>> _companies;
  late Future<List<User>> _drivers;

  @override
  void initState() {
    super.initState();
    _companies = widget.adminService.getAllCompanies(widget.token);
    _drivers = widget.adminService.getAllDrivers(widget.token);
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
            child: FutureBuilder<List<Company>>(
              future: _companies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No companies found'));
                } else {
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var company = snapshot.data![index];
                          return ListTile(
                            title: Text(company.name), 
                            subtitle: Text('ID: ${company.id}'),
                            onTap: () {
                              Future<List<User>> drivers = widget.adminService.getDriversByCompanyId(company.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriversView(driversFuture: drivers, adminService: widget.adminService,),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompaniesView(companiesFuture: _companies, token: widget.token),
                            ),
                          );
                        },
                        child: const Text('Show All Companies'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var driver = snapshot.data![index];
                          return ListTile(
                            title: Text(driver.firstName),
                            subtitle: Text('Driver ID: ${driver.id}'),
                            onTap: () {
                              var logs = widget.adminService.getLogsByDriverId(driver.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogsView(logsFuture: logs),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriversView(adminService: widget.adminService, driversFuture: _drivers),
                            ),
                          );
                        },
                        child: const Text('Show All Drivers'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
