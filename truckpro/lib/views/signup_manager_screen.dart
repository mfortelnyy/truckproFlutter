import 'package:flutter/material.dart';
import '../utils/admin_api_service.dart';

class SignUpManagerScreen extends StatelessWidget {
  final AdminApiService adminService;
  final String token;

  const SignUpManagerScreen({super.key, required this.adminService, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Manager'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add manager sign-up logic here
          },
          child: const Text('Sign Up Manager'),
        ),
      ),
    );
  }
}
