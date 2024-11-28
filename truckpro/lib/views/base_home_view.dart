import 'package:flutter/material.dart';
import 'dart:async';
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Enter the verification code sent to your email:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // Center align the buttons
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isDialogShowing = false;
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space between the row of buttons and Resend button
            Center(
              child: TextButton(
                onPressed: isResendEnabled ? _handleResendCode : null,
                child: Text(
                  isResendEnabled ? 'Resend Code' : 'Resend in 1 minute',
                  style: TextStyle(
                    color: isResendEnabled ? Colors.blueAccent : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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

  // Disable resend button for 60 seconds using Future.delayed
  Future.delayed(const Duration(seconds: 60), () {
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

Widget buildDeleteAccountButton() {
  return IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    tooltip: 'Delete Account',
    onPressed: _showDeleteAccountDialog,
  );
}

// Inside BaseHomeView
Widget buildSettingsPopupMenu() {
  return PopupMenuButton<int>(
    onSelected: (value) {
      if (value == 0) {
        _showDeleteAccountDialog();
      }
    },
    itemBuilder: (BuildContext context) => [
      const PopupMenuItem<int>(
        value: 0,
        child: Text('Delete Account'),
      ),
    ],
  );
}



void _showDeleteAccountDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAccount();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteAccount() async {
  try {
    final result = await LoginService().deleteAccount(token!);
    if (result!.contains("successfully")) {
      await widget.sessionManager.clearSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
      );
      _showSnackBar('Your account has been successfully deleted.');
    } else {
      _showSnackBar('Failed to delete account. Please try again later.');
    }
  } catch (e) {
    _showSnackBar('An error occurred while deleting the account: $e');
  }
}

}
