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
    
    if (res!=null && res!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful ${res}')),
        
      );
    } else {
      _showErrorDialog('Failed to register user. ${res}');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            DropdownButton<int>(
              hint: Text('Select Company'),
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
            ),
            ElevatedButton(
              onPressed: _handleSignup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
