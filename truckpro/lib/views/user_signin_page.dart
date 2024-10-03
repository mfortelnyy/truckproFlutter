import 'package:flutter/material.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/views/driver_signup_page.dart';

import '../utils/admin_api_service.dart';
import 'admin_home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
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
    if (token != null && token.length > 50) {
      //decode JWT token to get the role
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      //get the role from the token
      String role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      print('role: ${role}');

      //navigate to the appropriate homepage based on the role
      if (role == 'manager') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token)),
        );
      } else if (role == 'driver') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token)),
        );
      } else if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token)),
        );
      } else {
        //default
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token)),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Email input field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // password input field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Log In button
                ElevatedButton(
                  onPressed: () => _handleSignIn(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Log In'),
                ),

                const SizedBox(height: 10),

                // sign up button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DriverSignupPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.green, 
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
