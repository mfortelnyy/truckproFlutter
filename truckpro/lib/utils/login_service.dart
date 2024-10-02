import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http; 
import '../models/user.dart'; 

class LoginService {
  //base url of .net truckApi
  final String _baseUrl = 'https://localhost:443';

  //handles user login
  Future<String?> loginUser(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/Login');
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
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Redirect location: ${response.headers['location']}');

      if (response.statusCode == 200) {
        //if the server returns a successful response, parse the JSON. 
        String responseBody = response.body;
        //split string by the token, choose the right side with token and trim the whitespace
       var token = responseBody.split("Token: ")[1].trim();
       print("token:    ${token}");
       return token;

      } else {
        //if the server returns an error, throw an exception.
        throw Exception('Failed to log in + ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return ""; 
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