import 'package:flutter/material.dart';
import 'package:truckpro/utils/adminApiService.dart';
import 'package:truckpro/views/AdminHomePage.dart';
//import 'package:truckpro/views/MyHomePage.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

//import 'ManagerHomePage.dart'; 
//import 'DriverHomePage.dart';  

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService(); 

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //handle sign in and navigation based on role
  void _handleSignIn(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    print('${email} + "    " + ${password}');
    String? token = await _loginService.loginUser(email, password);
    print("token: ${token}");
    if (token != null && token.length>50) {
      //decode JWT token to get the role
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      //get the role from the token 
      String role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']; 
      print('role: ${role}');

      //if (!mounted) return;


      //navigate to the appropriate homepage based on the role
      if (role == 'manager') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token,)),
        );
      } else if (role == 'driver') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token,)),
        );
      } else if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token,)),
        );
      } else {
        //default
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token,)),
        );
      }
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () => _handleSignIn(context),
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

