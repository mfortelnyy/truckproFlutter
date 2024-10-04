import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/models/user.dart';

class ManagerApiService {
  final String baseUrl = 'https://localhost:443'; 
  final String token;    

  ManagerApiService({required this.token});

  //add drivers from an Excel file
  Future<String> addDriversToCompany(int companyId, List<int> fileBytes) async {
    final url = Uri.parse('$baseUrl/addDriversToCompany');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: 'drivers.xlsx'));

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        return json.decode(responseBody.body)['message'];
      } else {
        throw Exception('Failed to add drivers: ${responseBody.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // send emails to pending users
  Future<String> sendEmailToPendingUsers() async {
    final url = Uri.parse('$baseUrl/sendEmailToPendingUsers');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'];
      } else {
        throw Exception('Failed to send emails: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //get all active driving logs
  Future<List<LogEntry>> getAllActiveDrivingLogs() async {
    final url = Uri.parse('$baseUrl/getAllActiveDrivingLogs');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        return jsonList.map((json) => LogEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch active driving logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //approve driving log by ID
  Future<String> approveDrivingLogById(int logEntryId) async {
    final url = Uri.parse('$baseUrl/approveDrivingLogById?logEntryId=$logEntryId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'];
      } else {
        throw Exception('Failed to approve driving log: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //get all drivers by company
  Future<List<User>> getAllDriversByCompany() async {
    final url = Uri.parse('$baseUrl/getAllDriversByCompany');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch drivers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //get logs by driver ID
  Future<List<LogEntry>> getLogsByDriverId(int driverId) async {
    final url = Uri.parse('$baseUrl/geLogsByDriverId?driverId=$driverId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);;
        return jsonList.map((json) => LogEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // get images of driving log
  Future<List<dynamic>> getImagesOfDrivingLog(int drivingLogId) async {
    final url = Uri.parse('$baseUrl/getImagesOfDrivingLog?drivingLogId=$drivingLogId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch images: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // get registered users from pending users
  Future<List<User>> getRegisteredFromPending() async {
    final url = Uri.parse('$baseUrl/getRegisteredFromPending');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        return jsonList.map((json) => User.fromJson(json)).toList(); 
      } else {
        throw Exception('Failed to fetch registered users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // get not registered users from pending users
  Future<List<PendingUser>> getNotRegisteredFromPending() async {
    final url = Uri.parse('$baseUrl/getNotRegisteredFromPending');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        return jsonList.map((json) => PendingUser.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch not registered users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
