import 'package:flutter/material.dart';
import 'views/driver_signin_page.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: SignInPage(),
    );
  }
}




