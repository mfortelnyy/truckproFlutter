using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
import 'dart:convert'; //for JSON encoding/decoding
import 'package:http/http.dart' as http; 

namespace lib.utils
{
    public class AdminApiService
    {
        final String baseUrl = 'https://';

        Future<List<dynamic>> getAllCompanies() async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllCompanies'));

            if (response.statusCode == 200) {
            return json.decode(response.body);
            } else {
            throw Exception('Failed to load companies');
            }
        }

        Future<List<dynamic>> getAllDrivers() async {
            final response = await http.get(Uri.parse('$baseUrl/adm/getAllDrivers'));

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
}