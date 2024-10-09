import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/models/user.dart';

class ManagerApiService {
  final String baseUrl = 'https://localhost:443'; 
  

  ManagerApiService();

  //add drivers from an Excel file
  Future<String> addDriversToCompany(String filePath, String token) async {
    final url = Uri.parse('$baseUrl/addDriversToCompany');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';
    
    // read the file from the file path and add it as MultipartFile
    var fileBytes = await http.MultipartFile.fromPath('file', filePath);

    request.files.add(fileBytes);

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
  Future<String> sendEmailToPendingUsers(String token) async {
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
  Future<List<LogEntry>> getAllActiveDrivingLogs(String token) async {
    final url = Uri.parse('$baseUrl/getAllActiveDrivingLogs');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        
        List<dynamic> jsonList = json.decode(response.body);
        
        return jsonList.map<LogEntry>((json) => LogEntry.fromJson(json)).toList();

      } else {
        throw Exception('Failed to fetch active driving logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //approve driving log by ID
  Future<String> approveDrivingLogById(int logEntryId, String token) async {
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

  //get all drivers by company of the manager
  Future<List<User>> getAllDriversByCompany(String token) async {
    final url = Uri.parse('$baseUrl/getAllDriversByCompany');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print("getting all comanies response code: ${response.statusCode}");
      if (response.statusCode == 200) {
           List<dynamic> jsonList = json.decode(response.body);
           var result = jsonList.map((json) => User.fromJson(json)).toList(); 
           return result;
      } else {
        throw Exception('Failed to fetch drivers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //get logs by driver ID
  Future<List<LogEntry>> getLogsByDriverId(int driverId, String token) async {
    final url = Uri.parse('$baseUrl/allLogsByDriver?driverId=$driverId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List<dynamic>;
        var res = jsonList.map((json) => LogEntry.fromJson(json)).toList();
        return res;
        //[{"id":1,"userId":2,"user":null,"startTime":"2024-09-19T01:16:25.6739627","endTime":null,"logEntryType":1,"imageUrls":null,"isApprovedByManager":false},{"id":2,"userId":2,"user":null,"startTime":"2024-09-19T02:52:22.2764388","endTime":null,"logEntryType":0,"imageUrls":["https://truckphotos.s3.amazonaws.com/a609e165-85c8-4a0b-b331-b6bce94c0489_1.png","https://truckphotos.s3.amazonaws.com/c67e03b7-e2c6-47b3-a1cf-de9d455ccc41_download.jfif"],"isApprovedByManager":false}]
      } else {
        throw Exception('Failed to fetch logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  // get images of driving log
  Future<List<String>> getImagesOfDrivingLog(int drivingLogId, String token) async {
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
  Future<List<User>> getRegisteredFromPending(String token) async {
    final url = Uri.parse('$baseUrl/getRegisteredFromPending');

    print("manager with token $token");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        return jsonList.map<User>((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch registered users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // get not registered users from pending users
  Future<List<PendingUser>> getNotRegisteredFromPending(String token) async {
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
  
        return jsonList.map<PendingUser>((json) => PendingUser.fromJson(json)).toList();
 
      } else {
        throw Exception('Failed to fetch not registered users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
/*
  Future<String> approveDrivingLogById(int logEntryId, String token) async{
    final url = Uri.parse('$baseUrl/approveDrivingLogById?logEntryId=${logEntryId}');
    try {
      final response = await http.post(
        url,
        headers: {

        'Content-Type': 'application/json', 
      
          'Authorization': 'Bearer $token',
        },

        
      );
      print("APPROVING DRIVING LOG RESPONSE CODE: ${response.statusCode}");
      if (response.statusCode == 200) {
        return "Log with id: ${logEntryId} succesfully approved";
      }
      else{
        throw Exception("Log can not be approved at this moment");
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  */

  Future<List<String>> getSignedUrls(List<String> urls, String token) async {
    final url = Uri.parse('$baseUrl/getSignedUrls');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(urls),
        headers: {

        'Content-Type': 'application/json', 
      
          'Authorization': 'Bearer $token',
        },

        
      );
      print("getting signed images reponse code: ${response.statusCode}");
      if (response.statusCode == 200) {
        var  jsonList = json.decode(response.body);
        if(jsonList.isNotEmpty)
        {
          return jsonList;
          //return jsonList.map((json) => PendingUser.fromJson(json)).toList();
        }
        else
        {
          throw Exception('Failed to signed urls: ${response.body}');
        }
      } else {
        throw Exception('Failed to signed urls:: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }

  }


  Future<List<PendingUser>> getAllPendingUsers(String token) async {
    final url = Uri.parse('$baseUrl/getAllPendingUsers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body);
        if(jsonList.isNotEmpty)
        {
          return jsonList.map<PendingUser>((json) => PendingUser.fromJson(json)).toList();
        }
        else
        {
          throw Exception('Failed to fetch not registered users: ${response.body}');
        }
      } else {
        throw Exception('Failed to fetch not registered users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

   Future<String> deletePendingUser(String token, int userId) async {
      final url = Uri.parse('$baseUrl/deletePendingUser?userId=$userId');

      try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        if(res > 0)
        {
          return "Succesfully Deleted Pending User";
        }
        else
        {
          throw Exception('Failed to delete pending user: ${response.body}');
        }
      } else {
        throw Exception('Failed to delete pending user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }


}
    



}