import 'package:flutter/material.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/views/driver_home_page.dart';
import 'package:truckpro/views/driver_signup_page.dart';
import 'package:truckpro/views/forgot_password_view.dart';
import 'package:truckpro/views/manager_home_page.dart';

import '../utils/admin_api_service.dart';
import '../utils/session_manager.dart';
import 'admin_home_page.dart';

class SignInPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  const SignInPage({super.key, required this.toggleTheme});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool isDarkMode = false; 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  final SessionManager _sessionManager = SessionManager(); 
 
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
    String? token = await _loginService.loginUser(email, password);
    
    if (token != null && token.length > 50) {
      //decode JWT token to get the role
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      
      String userId = decodedToken['userId']; 

      await _sessionManager.saveSession(token, int.parse(userId));

      //navigate to the appropriate homepage based on the role
      switch (role) {
        case "Admin":
          Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AdminHomePage(adminService: AdminApiService(), token: token, sessionManager: _sessionManager, toggleTheme: widget.toggleTheme,)),
          );
        case "Manager":
          Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ManagerHomeScreen(token: token, sessionManager: _sessionManager, toggleTheme: widget.toggleTheme,)),
          );
        case "Driver":
          Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DriverHomeView(token: token, sessionManager: _sessionManager, toggleTheme: widget.toggleTheme,)),
          );
          break;
        default:
      }
      
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }
   @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Log In'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {

              setState(() {
                isDarkMode = !isDarkMode;
              });
              widget.toggleTheme(isDarkMode); 
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/registration_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.black), 
                        filled: true,
                        fillColor: const Color.fromARGB(227, 238, 178, 127).withOpacity(0.75),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 109, 219, 236), 
                            width: 2,
                          ),
                        ),
                        floatingLabelStyle: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 249, 249, 249), // label color when focused (floating above)
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color.fromARGB(227, 238, 178, 127).withOpacity(0.75),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 109, 219, 236), width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                        ),
                        floatingLabelStyle: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 249, 249, 249), 
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5), // Set border color with low opacity
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(20), // Circular border
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ForgotPasswordView()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color.fromARGB(198, 246, 241, 241),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => _handleSignIn(context), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 66, 164, 70),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      child: const Text('Log In', style: TextStyle(color:Colors.white ),),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DriverSignupPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      child: const Text('Sign Up', style: TextStyle(color:Colors.white ),),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
}

 }
