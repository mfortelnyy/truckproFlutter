import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truckpro/utils/login_service.dart';

class ForgotPasswordView extends StatefulWidget {
  final LoginService loginService = LoginService();
  ForgotPasswordView({super.key});

  @override
  ForgotPasswordViewState createState() => ForgotPasswordViewState();
}

class ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isButtonDisabled = false;
  Timer? _timer;
  int _countdown = 60; // 60 seconds cooldown

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _isButtonDisabled = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _isButtonDisabled = false;
          _countdown = 60; // Reset the timer
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        elevation: 10,
      ),
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
                    ElevatedButton(
                      onPressed: _isButtonDisabled
                          ? null
                          : () async {
                              final email = _emailController.text;
                              if (email.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  var res = await widget.loginService.forgetPassword(email);
                                  if (res != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email sent successfully!'),
                                        backgroundColor: Color.fromARGB(219, 79, 194, 70),
                                      ),
                                    );
                                    _startCooldownTimer(); // Start cooldown if successful
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to send an email!'),
                                      backgroundColor: Color.fromARGB(230, 247, 42, 66),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter an email address'),
                                    backgroundColor: Color.fromARGB(198, 244, 134, 55),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonDisabled
                            ? Colors.grey
                            : const Color.fromARGB(255, 241, 158, 89).withOpacity(0.88),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 158, 236, 221),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : _isButtonDisabled
                              ? Text('Retry in $_countdown seconds',
                                  style: const TextStyle(fontSize: 18, color: Colors.white))
                              : const Text('Send Reset Email',
                                  style: TextStyle(fontSize: 18, color: Colors.white)),
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
