
import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'package:truckpro/models/company.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/manager_signup_dto.dart';
import 'package:truckpro/models/user.dart'; 

    class AdminApiService
    {
        final String baseUrl = 'https://localhost:443';

        Future<List<Company>> getAllCompanies(String token) async {
          //print("token passed:  $token");
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllCompanies'), 
                                            headers: 
                                              {
                                                "Content-Type": "application/json",
                                                "Authorization": "Bearer $token"
                                                
                                              });
            print("response in get all comapnies ${response.statusCode}");
            if (response.statusCode == 200) {
            List<dynamic> jsonList = json.decode(response.body);
            return jsonList.map((json) => Company.fromJson(json)).toList(); // map JSON to Company objects
            } else {
            throw Exception('Failed to load companies');
            }
        }

        Future<List<User>> getAllDrivers(String token) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllDrivers'),
                                            headers: 
                                              {
                                                "Content-Type": "application/json",
                                                "Authorization": "Bearer $token"
                                                
                                              });
            print("get all drivers response code: ${response.statusCode}");
            if (response.statusCode == 200) {
            List<dynamic> jsonList = json.decode(response.body);
            return jsonList.map((json) => User.fromJson(json)).toList(); // map JSON to User objects
            } else {
            throw Exception('Failed to load drivers');
            }
        }

        Future<User> getDriverById(int userId) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getDriverById?userId=$userId'));

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load driver');
            }
        }

        Future<List<User>> getDriversByCompanyId(int? companyId, String token) async {
            
            if(companyId == null) throw new Exception("null compnay id");
            final response = await http.get(Uri.parse('$baseUrl/adm/getDriversByCompanyId?companyId=$companyId'),
                                            headers: 
                                              {
                                                "Content-Type": "application/json",
                                                "Authorization": "Bearer $token"
                                                
                                              });

            if (response.statusCode == 200) {
              List<dynamic> jsonList = json.decode(response.body);
              return jsonList.map((json) => User.fromJson(json)).toList(); 
            } else {
            throw Exception('Failed to load drivers');
            }
        }

        Future<List<LogEntry>> getLogsByDriverId(int driverId) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getLogsByDriverId?driverId=$driverId'));

            if (response.statusCode == 200) {
            List<dynamic> jsonList = json.decode(response.body);
            return jsonList.map((json) => LogEntry.fromJson(json)).toList();
            } else {
            throw Exception('Failed to load logs');
            }
        }

        Future<dynamic> createCompany(Company company, String token) async {
            final response = await http.post(
                Uri.parse('$baseUrl/adm/createCompany'),
                headers: {
                  'Authorization': 'Bearer $token',
                  "Content-Type": "application/json"
                  },
                body: json.encode(company.toJson()),
            );

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to create company');
            }
        }

        Future<String?> signUpManager(ManagerSignUpDto manager) async {
            final response = await http.post(
            Uri.parse('$baseUrl/signUpManager'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(manager.toJson()),
            );
        }

    }