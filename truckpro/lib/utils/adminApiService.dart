
import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http; 

    class AdminApiService
    {
        final String baseUrl = 'https://localhost:443';

        Future<List<dynamic>> getAllCompanies(String token) async {
          print("token passed:  $token");
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllCompanies'), 
                                            headers: 
                                              {
                                                "Content-Type": "application/json",
                                                "Authorization": "Bearer $token"
                                                
                                              });
            print("response in get all comapnies ${response.statusCode}");
            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load companies');
            }
        }

        Future<List<dynamic>> getAllDrivers(String token) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllDrivers'),
                                            headers: 
                                              {
                                                "Content-Type": "application/json",
                                                "Authorization": "Bearer $token"
                                                
                                              });
            print("get all drivers respinse code: ${response.statusCode}");
            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load drivers');
            }
        }

        Future<dynamic> getDriverById(int userId) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getDriverById?userId=$userId'));

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load driver');
            }
        }

        Future<List<dynamic>> getDriversByCompanyId(int companyId) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getDriversByCompanyId?companyId=$companyId'));

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load drivers');
            }
        }

        Future<List<dynamic>> getLogsByDriverId(int driverId) async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getLogsByDriverId?driverId=$driverId'));

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load logs');
            }
        }

        Future<dynamic> createCompany(Map<String, dynamic> companyData) async {
            final response = await http.post(
                Uri.parse('$baseUrl/adm/createCompany'),
                headers: {"Content-Type": "application/json"},
                body: json.encode(companyData),
            );

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to create company');
            }
        }



    }