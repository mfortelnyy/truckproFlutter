import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'package:truckpro/models/change_password_request.dart';
import 'package:truckpro/models/signup_request.dart'; 

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
       //print("token:    ${token}");
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

  // handle user sign-up
  Future<String?> registerUser(SignUpRequest signupDTO) async {
    try {
      final url = Uri.parse('$_baseUrl/signup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(signupDTO.toJson()),
      );
      print(response.statusCode);
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {

        return jsonDecode(response.body);
      } else {
        
        return jsonDecode(response.body);
      }
    } catch (e) {
      //print(e);
      return "";
    }
  }


  // handle user change of password
  Future<String?> updatePassword(ChangePasswordRequest cpr, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/updatePassword');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }, 
        body: jsonEncode(cpr.toJson()),
      ); //{"userId":3,"oldPassword":"SecurePassword123!","newPassword":"12345678"}
      //print("upd PASSWRD ${response.statusCode}");
      //print("RESPOSE BODY: ${jsonDecode(response.body)}");

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res['message'];
      } 
      else {
        throw Exception('Failed to update password!');
      }
    } catch (e) {
      //print(e);
      throw Exception(e.toString());
    }
  }

  // handle user forget password
  Future<String?> forgePassword(String token, String email) async {
    try {
      final url = Uri.parse('$_baseUrl/updatePassword');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }, 
        body: jsonEncode("'email': '$email'"),
      ); 
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res['message'];
      } 
      else {
        throw Exception('Failed to update password!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
