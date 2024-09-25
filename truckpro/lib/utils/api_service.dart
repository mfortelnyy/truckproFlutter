import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http; 
import '../models/user.dart'; 

class ApiService {
  //base url of .net truckApi
  final String _baseUrl = 'https://your-api-url.com/api';

  //handles user login
  Future<User?> loginUser(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        //if the server returns a successful response, parse the JSON.
        return User.fromJson(jsonDecode(response.body));
      } else {
        //if the server returns an error, throw an exception.
        throw Exception('Failed to log in');
      }
    } catch (e) {
      //print(e);
      return null; 
    }
  }

  // Function to handle user sign-up
  Future<User?> registerUser(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/signup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      //print(e);
      return null;
    }
  }
}
