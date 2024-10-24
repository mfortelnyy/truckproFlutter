import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/theme/color_schema.dart';
import 'package:truckpro/views/admin_home_page.dart';
import 'utils/admin_api_service.dart';
import 'utils/session_manager.dart';
import 'views/driver_home_page.dart';
import 'views/manager_home_page.dart';
import 'views/user_signin_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // def to light

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // load theme pref 
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to light mode if no preference is saved
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // save theme pref to Shared prefs
  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  // toggle between light and dark theme
  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
    _saveThemePreference(isDarkMode);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckPro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: _themeMode, 
      home: SplashScreen(toggleTheme: _toggleTheme),  //checks session
      //darkTheme: ThemeData.from(colorScheme: darkColorScheme),
      debugShowCheckedModeBanner: false , 
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  SplashScreen({required this.toggleTheme});


  
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null && JwtDecoder.isExpired(token) == false) {
      // Token is valid and not expired
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

      // Navigate based on role
      switch (role) {
        case "Admin":
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token, sessionManager: _sessionManager, toggleTheme: widget.toggleTheme)),
          );
          break;
        case "Manager":
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerHomeScreen(token: token, sessionManager:_sessionManager, toggleTheme: widget.toggleTheme,)),
          );
          break;
        case "Driver":
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DriverHomeView(token: token, sessionManager: _sessionManager, toggleTheme: widget.toggleTheme,)),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
          );
      }
    } else {
      // token is invalid or expired
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme,)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
