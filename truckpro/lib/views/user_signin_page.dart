import 'package:flutter/material.dart';
import 'package:truckpro/utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/views/driver_home_page.dart';
import 'package:truckpro/views/driver_signup_page.dart';
import 'package:truckpro/views/forgot_password_view.dart';
import 'package:truckpro/views/independent_driver_signup_view.dart';
import 'package:truckpro/views/manager_home_page.dart';
import '../utils/admin_api_service.dart';
import '../utils/firebase_service.dart';
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
  bool obscurePassword = true;
  bool loading = false; //loading state

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  final SessionManager _sessionManager = SessionManager();
  final FirebaseService _firebaseService = FirebaseService();



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

  Future<void> _handleSignIn(BuildContext context) async {
    setState(() {
      loading = true; 
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    String? token = await _loginService.loginUser(email, password);
    
    // Stop loading after the response
    setState(() {
      loading = false; 
    });

    if (token!.length > 50) {
      try
      {
        String? fcmToken = await _firebaseService.getDeviceToken();
        _loginService.sendDeviceToken(token, fcmToken);
      }catch(e)
      {
        print("DeviceToken Not Set Up!");
      }

      
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      String userId = decodedToken['userId'];

      await _sessionManager.saveSession(token, int.parse(userId));

      // Navigate to the appropriate homepage based on the role
      switch (role) {
        case "Admin":
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AdminHomePage(
              adminService: AdminApiService(),
              token: token,
              sessionManager: _sessionManager,
              toggleTheme: widget.toggleTheme,
            ),
          ));
          break;
        case "Manager":
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ManagerHomeScreen(
              token: token,
              sessionManager: _sessionManager,
              toggleTheme: widget.toggleTheme,
            ),
          ));
          break;
        case "Driver":
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DriverHomeView(
              token: token,
              sessionManager: _sessionManager,
              toggleTheme: widget.toggleTheme,
            ),
          ));
          break;
        default:
          _showErrorDialog('Unknown role');
      }
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgimg.jpeg'),
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
                        fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
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
                        
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 109, 219, 236),
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 30, 
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 197, 188, 188).withOpacity(0.88)),
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              overlayColor: WidgetStateProperty.all<Color>(
                                  Colors.grey.withOpacity(0.2)),
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : () {
                                    // Independent Driver Sign Up page
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const IndependentDriverSignupPage()),
                                    );
                                  },
                            child: const Text(
                              'Not a company driver?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), 
                        SizedBox(
                          width: 160, 
                          height: 30,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 197, 188, 188).withOpacity(0.88)),
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              overlayColor: WidgetStateProperty.all<Color>(
                                  Colors.grey.withOpacity(0.2)),
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : () {
                                    // Forgot Password page
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ForgotPasswordView()),
                                    );
                                  },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: loading ? null : () => _handleSignIn(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 66, 164, 70),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const DriverSignupPage()),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            //loading indicator 
            if (loading)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }
  }
