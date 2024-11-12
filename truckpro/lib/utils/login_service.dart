import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'package:truckpro/models/change_password_request.dart';
import 'package:truckpro/models/signup_request.dart';
import 'package:truckpro/models/userDto.dart'; 

class LoginService {

  //base url of .net truckApi
  //final String _baseUrl = 'https://localhost:443';  'https://stunning-tadpole-deadly.ngrok-free.app'; 
  final String _baseUrl = 'https://truckcheck.org:443'; 

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
      final url = Uri.parse('$_baseUrl/signup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(signupDTO.toJson()),
      );
      //print(response.statusCode);
      //print(jsonDecode(response.body));

      
      return jsonDecode(response.body)['message'];
  
  }


  // handle user change of password
  Future<String?> updatePassword(ChangePasswordRequest cpr, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/updatePassword');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }, 
        body: jsonEncode(cpr.toJson()),
      ); //{"userId":3,"oldPassword":"SecurePassword123!","newPassword":"12345678"}
      //print("upd PASSWRD ${response.statusCode}");
      //print("RESPOSE BODY: ${jsonDecode(response.body)}");
      var res = json.decode(response.body);
      if (response.statusCode == 200) {
        
        return res['message'];
      } 
      else {
        throw Exception('Failed to update password! ${res['message']}');
      }
    } catch (e) {
      //print(e);
      throw Exception(e.toString());
    }
  }

  // handle user forget password
  Future<String?> forgetPassword(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/forgetPassword');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // form-urlencoded
        },
        body: {
          'email': email,  // Form data
        },
      );
      if (response.statusCode == 200) { 
        var res = json.decode(response.body);
        return res['message'];
      } 
      else {
        throw Exception('Failed to send temporary password!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> verifyEmail(String token, String code) async
  {
    try {
      final url = Uri.parse('$_baseUrl/verifyEmail');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'EmailCode' : code
        }, 
        
      ); 

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        var result = jsonList['message'];

        return result;
      } 
      else {
        throw Exception('Failed to verify email!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }



  Future<UserDto> getUserById(String token) async
  {
    try {
      final url = Uri.parse('$_baseUrl/getUserbyToken');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }, 
        
      ); 

      if (response.statusCode == 200) {
        var jsonUserDto = json.decode(response.body);
        var userDto = UserDto.fromJson(jsonUserDto);

        return userDto;
      } 
      else {
        throw Exception('Failed to get user!');
      }
    } catch (e) {
      //print(e);
      throw Exception(e.toString());
    }
  }

  Future<String> reSendEmailCode(String token, String email) async
  {
    try {
      final url = Uri.parse('$_baseUrl/reSendEmailVerificationCode');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Email': email, 
        }, 
        
      ); 
      var jsonUserDto = json.decode(response.body);
      var res = jsonUserDto['message'];
      if (response.statusCode == 200) {
        return res;
      } 
      else {
        throw Exception(res);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

}
