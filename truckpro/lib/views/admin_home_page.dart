import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';
import '../models/user.dart';
import '../utils/admin_api_service.dart';
import 'companies_view.dart'; 
import 'create_company_screen.dart';
import 'drivers_view.dart';
import 'logs_view.dart';
import 'signup_manager_screen.dart'; 

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
      drawer: _buildDrawer(context),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var company = snapshot.data![index];
                            return ListTile(
                              title: Text(company.name), 
                              subtitle: Text('ID: ${company.id}'),
                              onTap: () {
                                Future<List<User>> drivers = widget.adminService.getDriversByCompanyId(company.id, widget.token);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriversView(driversFuture: drivers, adminService: widget.adminService,companyName: company.name,),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
                      Expanded(
                        child: ListView.builder(
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
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriversView(adminService: widget.adminService, driversFuture: _drivers, companyName: null,),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: const Text('Create Company'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCompanyScreen(adminService: widget.adminService, token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: const Text('Sign Up Manager'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUpManagerScreen(adminService: widget.adminService, token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
