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
                      onPressed: () async {
                        final email = _emailController.text;
                        if (email.isNotEmpty) {
                          try
                          {
                            await widget.loginService.forgetPassword(email); // call the function to send email
                          }
                          catch(e)
                          { 
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send an email!')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an email address')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 241, 158, 89).withOpacity(0.88),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 158, 236, 221), fontWeight: FontWeight.w400),
                      ),
                      child: const Text('Send Reset Email', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),),
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
