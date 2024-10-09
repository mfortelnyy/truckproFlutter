import 'package:flutter/material.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import '../models/signup_request.dart';
import '../utils/login_service.dart';

class DriverSignupPage extends StatefulWidget {
  const DriverSignupPage({super.key});

  @override
  DriverSignupPageState createState() => DriverSignupPageState();
}

class DriverSignupPageState extends State<DriverSignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AdminApiService _adminService = AdminApiService(); 
  final LoginService _loginService = LoginService(); 

  var _companies = [];
  int? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final companies = await _adminService.getAllCompanies("token"); 
      setState(() {
        _companies = companies;
      });
    } catch (e) {
      print('Error fetching companies: $e');
    }
  }

  void _handleSignup() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // ensures company is selected
    if (_selectedCompanyId == null) {
      _showErrorDialog('Please select a company.');
      return;
    }

    // validate email format
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      _showErrorDialog('Invalid email format');
      return;
    }

    // validate password matching
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match!');
      return;
    }

    // create DTO for signup
    SignUpRequest signupDTO = SignUpRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phone,
      companyId: _selectedCompanyId!, 
    );

    // make the signup request
    String? res = await _loginService.registerUser(signupDTO);
    
    if (res!=null && res.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful $res')),
        
      );
    } else {
      _showErrorDialog('Failed to register user. $res');
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
              _buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 16),
              _buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number'),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
              const SizedBox(height: 24),
              _buildDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
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
            ],
          ),
        ),
      ),
    );  
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          fillColor: Colors.white,
          filled: true,
        ),
      );
    }


  Widget _buildDropdown() {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Select Company',
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          fillColor: Colors.white,
          filled: true,
        ),
        value: _selectedCompanyId,
        onChanged: (int? newValue) {
          setState(() {
            _selectedCompanyId = newValue;
          });
        },
        items: _companies.map((company) {
          return DropdownMenuItem<int>(
            value: company.id,
            child: Text(company.name),
          );
        }).toList(),
      );
    }
  }

