import 'package:flutter/material.dart';
import 'package:studentapp/utils/DBHelper.dart';
import 'package:studentapp/views/MyHomePage.dart';
import 'package:studentapp/views/taskGridWidget.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleSignIn(BuildContext context) async {
    final email = _emailController.text;
    final password = sha_256(_passwordController.text);
    final dbHelper = DBHelper();

    final user = await dbHelper.getUserByEmail(email);
    
    if (user != null && user.password == password) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(user),
        ),
      );
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () => _handleSignIn(context),
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
  
  String sha_256(String s){
    return s;
  }
}
