import 'package:flutter/material.dart';
import 'package:studentapp/utils/DBHelper.dart';
import 'package:studentapp/models/student.dart';
import 'package:studentapp/views/StudentSigninPage.dart';
class StudentSignupPage extends StatefulWidget {
  @override
  _StudentSignupPageState createState() => _StudentSignupPageState();
}

class _StudentSignupPageState extends State<StudentSignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _handleSignup() async {
    // Get user input
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = sha_256(_passwordController.text);

    // Validate email format
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      _showErrorDialog('Invalid email format');
      return;
    }

    // Check if the email already exists
    Student? existingUser = await DBHelper().getUserByEmail(email);

    if (existingUser != null) {
      _showErrorDialog('Email already exists. Please use a different email.');
      return;
    }
    

    // Create a Student object
    final Student student = Student(name: name, email: email, password: password);

    // Save the student in the database
    final dbHelper = DBHelper();
    dbHelper.insertStudent(student);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: _handleSignup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  String sha_256(String s){
    return s;
  }
}
