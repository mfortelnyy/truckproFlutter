import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckpro/models/manager_signup_dto.dart';
import 'package:truckpro/utils/admin_api_service.dart';

class ManagerSignupView extends StatefulWidget {
  final String token;
  final VoidCallback onManagerCreated;  //callback function
  const ManagerSignupView({super.key, required this.token, required this.onManagerCreated});

  @override
  ManagerSignupViewState createState() => ManagerSignupViewState();
}

class ManagerSignupViewState extends State<ManagerSignupView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AdminApiService _adminService = AdminApiService(); 

  var _companies = [];
  int? _selectedCompanyId;
  bool isDark = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  
  //loading indicator state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
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

  Future<void> _fetchCompanies() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      isDark = sp.getBool('isDarkMode') ?? false;
      final companies = await _adminService.getAllCompanies("token"); 
      setState(() {
        _companies = companies;
      });
    } catch (e) {
      _showErrorDialog('Failed to fetch companies. ${e.toString().split(":").last}');
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
    ManagerSignUpDto managerSignupDTO = ManagerSignUpDto(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phone: phone,
      role: 1,
      companyId: _selectedCompanyId!, 
    );

    //display loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      String? res = await _adminService.signUpManager(managerSignupDTO, widget.token);
    
      setState(() {
        _isLoading = false;
      });

      if (res!.length == 6) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!'), backgroundColor: Color.fromARGB(219, 79, 194, 70)),
          );
        }
      } else {
        _showErrorDialog('Failed to register user. $res');
      } 
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to register user. ${e.toString().split(":").last}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Registration'),
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
              _buildTextField(_passwordController, 'Password'),
              const SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm Password'),
              const SizedBox(height: 24),
              _buildDropdown(),
              const SizedBox(height: 24),

              //loading spinner if the form is submitting
              AnimatedOpacity(
                opacity: _isLoading ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 158, 89),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                   //disable button when loading
                  onPressed: _isLoading ? null : _handleSignup, 
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildTextField(TextEditingController controller, String label) {
    bool isPasswordField = label == "Password";
    bool isConfirmPasswordField = label == "Confirm Password";
    
    return TextField(
      controller: controller,
      obscureText: isPasswordField ? obscurePassword : (isConfirmPasswordField ? obscureConfirmPassword : false),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: isDark ? const TextStyle(color: Colors.white) : const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        fillColor: const Color.fromARGB(82, 248, 243, 243),
        filled: true,
        suffixIcon: (isPasswordField || isConfirmPasswordField) 
          ? IconButton(
              icon: Icon(
                (isPasswordField ? obscurePassword : obscureConfirmPassword)
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  if (isPasswordField) {
                    obscurePassword = !obscurePassword;
                  } else {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  }
                });
              },
            )
          : null,
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

