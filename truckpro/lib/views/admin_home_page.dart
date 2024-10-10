import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';
import 'package:truckpro/views/drivers_view_admin.dart';
import 'package:truckpro/views/managers_view.dart';
import '../models/user.dart';
import '../utils/admin_api_service.dart';
import 'companies_view.dart'; 
import 'create_company_screen.dart';
import 'drivers_view_manager.dart';
import 'logs_view.dart';
import 'manager_signup_view.dart';
import 'update_password_view.dart';
import 'user_signin_page.dart'; 

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
  late Future<List<User>> _managers;

  @override
  void initState() {
    super.initState();
    _companies = widget.adminService.getAllCompanies(widget.token);
    _drivers = widget.adminService.getAllDrivers(widget.token);
    _managers = widget.adminService.getAllManagers(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: initState,
          ),
        ],
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black, 
          ),
        ),
        backgroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.black), 
        elevation: 0, 
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(company.name, style: const TextStyle(color: Colors.black)),
                                  subtitle: Text('ID: ${company.id}', style: TextStyle(color: Colors.grey[600])),
                                  onTap: () {
                                    Future<List<User>> drivers = widget.adminService.getDriversByCompanyId(company.id, widget.token);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DriversViewAdmin(
                                          driversFuture: drivers, 
                                          adminService: widget.adminService,
                                          companyName: company.name,
                                          token: widget.token,
                                        ),
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
                                builder: (context) => CompaniesView(companiesFuture: _companies, token: widget.token),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 241, 158, 89), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Show All Companies', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
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
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(driver.firstName, style: const TextStyle(color: Colors.black)),
                                  subtitle: Text('Driver ID: ${driver.id}', style: TextStyle(color: Colors.grey[600])),
                                  onTap: () {
                                    var logs = widget.adminService.getLogsByDriverId(driver.id, widget.token);
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
                                builder: (context) => DriversViewAdmin(adminService: widget.adminService, driversFuture: _drivers, companyName: null, token: widget.token,),
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
            ),
          ],
        ),
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
            child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.black), // Black icons
            title: const Text('Create Company', style: TextStyle(color: Colors.black)),
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
            leading: const Icon(Icons.person_add, color: Colors.black),
            title: const Text('Sign Up Manager', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagerSignupView(token: widget.token),
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
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.man_2_rounded, color: Colors.black),
            title: const Text('Get All Managers', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagersView(token: widget.token, managersFuture: _managers),
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
