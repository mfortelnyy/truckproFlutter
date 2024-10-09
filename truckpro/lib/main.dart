import 'package:flutter/material.dart';
import 'views/user_signin_page.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      home: SignInPage(),
    );
  }
}




