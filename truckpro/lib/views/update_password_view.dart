import 'package:flutter/material.dart';
import '../models/change_password_request.dart';
import '../utils/login_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class UpdatePasswordView extends StatefulWidget {
  final String token;

  const UpdatePasswordView({super.key, required this.token});

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
         _isLoading = false;
        _errorMessage = null;
      });

      try {
         //decode JWT token to get the userid
        Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
        var userId = decodedToken['userId'];
        if(_oldPasswordController.text == _newPasswordController.text)
        {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New password can not be the same as your old!')),
          );
        }
        else{
          ChangePasswordRequest cpr = ChangePasswordRequest(
            userId: int.parse(userId),
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          );
          String? res = await _loginService.updatePassword(cpr, widget.token);

          
          if(res!.isNotEmpty)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully!')),
            );
            Navigator.pop(context);
          }
          else
          {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update password.')),
            );

          
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update password: $e';
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
                      decoration: const InputDecoration(labelText: 'Old Password'),
                      obscureText: true,
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
                      decoration: const InputDecoration(labelText: 'New Password'),
                      obscureText: true,
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
                      decoration: const InputDecoration(labelText: 'Confirm New Password'),
                      obscureText: true,
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
