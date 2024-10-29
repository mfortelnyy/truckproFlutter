import 'package:flutter/material.dart';
import 'package:truckpro/models/userDto.dart';

import '../utils/login_service.dart';
import '../utils/session_manager.dart';
import 'user_signin_page.dart';

class BaseHomeView extends StatefulWidget {
  final SessionManager sessionManager;
  final Function(bool) toggleTheme;

  const BaseHomeView({required this.sessionManager, required this.toggleTheme, super.key});

  @override
  BaseHomeViewState createState() => BaseHomeViewState();
}

class BaseHomeViewState<T extends BaseHomeView> extends State<T> {
  String? token;
  UserDto? user;

  @override
  void initState() {
    super.initState();
    checkSession();
    checkEmailVerification();
  }

  Future<void> checkSession() async {
    await widget.sessionManager.autoSignOut();
    token = await widget.sessionManager.getToken();
    
    if (token == null) {
      widget.sessionManager.clearSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
      );
    }
  }

   void checkEmailVerification() async {
    try {
      //var userId = await widget.sessionManager.getUserId();
      user = await LoginService().getUserById(token!);
      if (user != null && !user!.emailVerified) {
        _showVerificationDialog();
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        TextEditingController verificationCodeController = TextEditingController();
        return AlertDialog(
          title: const Text('Email Verification Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Please enter the verification code sent to your email:'),
              const SizedBox(height: 16),
              TextField(
                controller: verificationCodeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                String verificationCode = verificationCodeController.text.trim();
                String res = await LoginService().verifyEmail(token!, verificationCode);
                if (res.isEmpty) {
                  _showSnackBar('Cannot verify email!');
                } else {
                  _showSnackBar('Email verified successfully!');
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Verify'),
            ),
            TextButton(
              onPressed: () async {
                try{
                  var res = await LoginService().reSendEmailCode(token!, user!.email);
                  res.isNotEmpty ? _showSnackBar(res) : _showSnackBar('Cannot resend email.');
                }
                catch(ex)
                {
                  _showSnackBar(ex.toString());

                }
              },
              child: Text('Resend Code to ${user!.email}'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base Home View'),
      ),
      body: const Center(
        child: Text('Shared functionality between different home views'),
      ),
    );
  }
}
