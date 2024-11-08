import 'package:flutter/material.dart';
import 'package:truckpro/views/user_signin_page.dart';
import '../models/change_password_request.dart';
import '../utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UpdatePasswordView extends StatefulWidget {
  final String token;
  final Function(bool) toggleTheme;

  const UpdatePasswordView({super.key, required this.token, required this.toggleTheme});

  @override
  _UpdatePasswordViewState createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final LoginService _loginService = LoginService();

  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
        var userId = decodedToken['userId'];

        if (_oldPasswordController.text == _newPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New password cannot be the same as your old password!')),
          );
        } else {
          ChangePasswordRequest cpr = ChangePasswordRequest(
            userId: int.parse(userId),
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          );
          String? res = await _loginService.updatePassword(cpr, widget.token);
          setState(() {
            _isLoading = false;
          });
          if (res!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Color.fromARGB(219, 79, 194, 70) ,),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
                );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update password.'), backgroundColor: Color.fromARGB(230, 247, 42, 66,),)
            );
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().split(":").last;
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    TextFormField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureOldPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: const Text('Update Password'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
