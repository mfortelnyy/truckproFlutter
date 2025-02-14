import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckpro/models/company.dart';
import 'package:truckpro/models/userDto.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:truckpro/utils/session_manager.dart';
import 'package:truckpro/views/drivers_view_admin.dart';
import 'package:truckpro/views/managers_view.dart';
import '../models/user.dart';
import '../utils/admin_api_service.dart';
import 'base_home_view.dart';
import 'companies_view.dart'; 
import 'create_company_screen.dart';
import 'logs_view_manager.dart';
import 'manager_signup_view.dart';
import 'update_password_view.dart';
import 'user_signin_page.dart'; 

class AdminHomePage extends BaseHomeView {
  final AdminApiService adminService;
  final String token;
  @override
  final SessionManager sessionManager;
  @override
  final Function(bool) toggleTheme;


  const AdminHomePage({super.key, required this.adminService, required this.token, required this.sessionManager, required this.toggleTheme, }) 
  : super(sessionManager: sessionManager, toggleTheme: toggleTheme);

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends BaseHomeViewState<AdminHomePage> {
  
  late Future<List<Company>> _companies;
  late Future<List<User>> _drivers;
  late Future<List<User>> _managers;
  @override
  UserDto? user;
  bool isDarkMode = false;

  Timer? _timer;



  @override
  void initState() {
    super.initState();
    _loadSettings();

     _companies = Future.value([]);
     _drivers = Future.value([]);
     _managers = Future.value([]);

     _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      super.checkEmailVerification();
    });
    
    
     fetchUser(); 
     fetchData();
     super.checkEmailVerification(); 
     
  }
  

  void fetchData() async {
    super.checkSession();
    
    setState(() {
      _companies =  widget.adminService.getAllCompanies(widget.token);
      _drivers = widget.adminService.getAllDrivers(widget.token);
      _managers = widget.adminService.getAllManagers(widget.token);
      
    });
    
  }

  void fetchUser() async 
  {
    user = await LoginService().getUserById(widget.token);
    setState(() {
    });
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
        title: user != null
                  ? Text('Welcome, ${user!.firstName} ${user!.lastName}',        
                    //spaceSize: 72,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  )
                  : const Text("Admin Home Page"),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89), 
        iconTheme: const IconThemeData(color: Colors.black), 
        elevation: 0, 
      ),
      drawer: _buildDrawer(context, widget.toggleTheme),
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
                                        builder: (context) => LogsViewManager(logsFuture: logs, token: widget.token, approve: false, driverId: driver.id,),
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

  Widget _buildDrawer(BuildContext context, Function(bool) toggleTheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
            leading: Icon(Icons.business, color: textColor), 
            title: Text('Create Company', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCompanyScreen(adminService: widget.adminService, token: widget.token, onCompanyCreated: fetchData),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add, color: textColor),
            title: Text('Sign Up Manager', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagerSignupView(token: widget.token, onManagerCreated: fetchData),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.password_rounded, color: textColor),
            title: Text('Change Password', style: TextStyle(color: textColor)),
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
            leading: Icon(Icons.man_2_rounded, color: textColor),
            title: Text('Get All Managers', style: TextStyle(color: textColor)),
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
            leading: Icon(Icons.exit_to_app, color: textColor),
            title: Text('Sign Out', style: TextStyle(color: textColor)),
            onTap: () {
              widget.sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInPage(toggleTheme: toggleTheme),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}