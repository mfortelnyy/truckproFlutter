import 'package:flutter/material.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import '../models/signup_request.dart';
import '../utils/login_service.dart';

class IndependentDriverSignupPage extends StatefulWidget {
  const IndependentDriverSignupPage({super.key});

  @override
  IndependentDriverSignupPageState createState() => IndependentDriverSignupPageState();
}
class IndependentDriverSignupPageState extends State<IndependentDriverSignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final LoginService _loginService = LoginService();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
  }


  void _handleSignup() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      _showErrorDialog('Invalid email format');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match!');
      return;
    }

    SignUpRequest signupDTO = SignUpRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phone,
      companyId: 0,
    );

    setState(() {
      _isLoading = true; 
    });

    try {
      String? res = await _loginService.registerIndepUser(signupDTO);

      setState(() {
        _isLoading = false; 
      });

      if (res != null && res.isNotEmpty && res.length == 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful'), backgroundColor: Color.fromARGB(219, 79, 194, 70)),
        );
      } else {
        _showErrorDialog('Failed to register user. $res');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to register user. ${e.toString()}');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // get the current theme (light or dark)
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_firstNameController, 'First Name', isDarkTheme),
              const SizedBox(height: 16),
              _buildTextField(_lastNameController, 'Last Name', isDarkTheme),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', isDarkTheme),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number', isDarkTheme),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', isDarkTheme, 
                obscureText: _isPasswordObscured, 
                toggleObscureText: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm Password', isDarkTheme, 
                obscureText: _isConfirmPasswordObscured, 
                toggleObscureText: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: _isLoading ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 158, 89),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleSignup,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    bool isDarkTheme, {
    bool obscureText = false, 
    VoidCallback? toggleObscureText}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkTheme ? Colors.white : Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDarkTheme ? Colors.white : Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDarkTheme ? Colors.white : Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        fillColor: isDarkTheme ? Colors.black : Colors.white,
        filled: true,
        suffixIcon: toggleObscureText != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDarkTheme ? Colors.white : Colors.black54,
                ),
                onPressed: toggleObscureText,
              )
            : null,
      ),
    );
  }

}
