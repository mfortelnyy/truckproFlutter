import 'package:flutter/material.dart';
import 'dart:async';
import 'package:truckpro/models/userDto.dart';
import '../utils/login_service.dart';
import '../utils/session_manager.dart';
import 'user_signin_page.dart';

class BaseHomeView extends StatefulWidget {
  final SessionManager sessionManager;
  final Function(bool) toggleTheme;

  const BaseHomeView({required this.sessionManager, required this.toggleTheme, Key? key}) : super(key: key);

  @override
  BaseHomeViewState createState() => BaseHomeViewState();
}

class BaseHomeViewState<T extends BaseHomeView> extends State<T> {
  String? token;
  UserDto? user;
  bool isDialogShowing = false;
  bool isResendEnabled = true;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> checkSession() async {
    await widget.sessionManager.autoSignOut();
    token = await widget.sessionManager.getToken();

    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
      );
    } else {
      await checkEmailVerification();
    }
  }

  Future<void> checkEmailVerification() async {
    if (token == null) return;

    try {
      user = await LoginService().getUserById(token!);
      if (user != null && !user!.emailVerified && !isDialogShowing) {
        _showVerificationDialog();
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  void _showVerificationDialog() {
    setState(() {
      isDialogShowing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController verificationCodeController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Email Verification Required',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Please enter the verification code sent to your email:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isDialogShowing = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String verificationCode = verificationCodeController.text.trim();
                String res = await LoginService().verifyEmail(token!, verificationCode);
                res.isEmpty
                    ? _showSnackBar('Cannot verify email!')
                    : _showSnackBar('Email verified successfully!');
                Navigator.of(context).pop();
                setState(() {
                  isDialogShowing = false;
                });
              },
              child: const Text('Verify'),
            ),
            TextButton(
              onPressed: isResendEnabled ? _handleResendCode : null,
              child: Text(
                isResendEnabled ? 'Resend Code to ${user!.email}' : 'Resend in 1 minute',
                style: TextStyle(color: isResendEnabled ? Colors.blue : Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleResendCode() async {
    setState(() {
      isResendEnabled = false;
    });

    try {
      var res = await LoginService().reSendEmailCode(token!, user!.email);
      res.isNotEmpty ? _showSnackBar(res) : _showSnackBar('Cannot resend email.');
    } catch (ex) {
      _showSnackBar(ex.toString());
    }

    // Start 1-minute timer
    _resendTimer = Timer(Duration(minutes: 1), () {
      setState(() {
        isResendEnabled = true;
      });
    });
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
