import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/views/admin_home_page.dart';
import 'utils/admin_api_service.dart';
import 'views/driver_home_page.dart';
import 'views/manager_home_page.dart';
import 'views/user_signin_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckPro',
      home: SplashScreen(), //checks session
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
            MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token)),
          );
          break;
        case "Manager":
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerHomeScreen(token: token)),
          );
          break;
        case "Driver":
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DriverHomeView(token: token)),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
      }
    } else {
      // token is invalid or expired
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage()),
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
