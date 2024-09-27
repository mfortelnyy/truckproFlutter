import 'package:flutter/material.dart';
import 'views/DriverSigninPage.dart';
import 'utils/adminApiService.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminApiService adminService = AdminApiService();

    return MaterialApp(
      home: SignInPage(),
    );
  }
}




