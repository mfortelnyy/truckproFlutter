import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:truckpro/models/log_entry.dart';

class DriverApiService {
  final String baseUrl;
  final String token;

  DriverApiService({required this.baseUrl, required this.token});

  Future<http.Response> _postRequest(String endpoint, {dynamic body}) async {
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    return await http.post(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: jsonEncode(body));
  }

  Future<List<String>> uploadPhotos(List<File> images) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/uploadPhotos'));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return List<String>.from(json.decode(responseBody));
    } else {
      throw Exception('Failed to upload photos');
    }
  }

  Future<String> createOnDutyLog() async {
    final response = await _postRequest('/createOnDutyLog');
    if (response.statusCode == 200) {
      return json.decode(response.body);  
    } else {
      throw Exception('Failed to create on-duty log');
    }
  }

  Future<String> createDrivingLog(List<File> images) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/createDrivingLog'));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return json.decode(responseBody); 
    } else {
      throw Exception('Failed to create driving log');
    }
  }


  Future<String> createOffDutyLog() async {
    final response = await _postRequest('/createOffDutyLog');
    if (response.statusCode == 200) {
      return json.decode(response.body);  
    } else {
      throw Exception('Failed to create off-duty log');
    }
  }

  Future<String> stopDrivingLog() async {
    final response = await _postRequest('/stopDrivingLog');
    if (response.statusCode == 200) {
      return json.decode(response.body);  
    } else {
      throw Exception('Failed to stop driving log');
    }
  }

  Future<String> stopOnDutyLog() async {
    final response = await _postRequest('/stopOnDutyLog');
    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to stop on-duty log');
    }
  }

  Future<String> stopOffDutyLog() async {
    final response = await _postRequest('/stopOffDutyLog');
    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to stop off-duty log');
    }
  }
}
