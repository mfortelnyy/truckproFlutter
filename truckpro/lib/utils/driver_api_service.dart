import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class DriverApiService {
  final String _baseUrl = 'https://localhost:443';

  final String token;

  DriverApiService({required this.token});

  Future<String> createOnDutyLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/createOnDutyLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'On Duty log created: ${response.body}';
    } else {
      throw Exception('Failed to create On Duty log: ${response.body}');
    }
  }

  Future<String> createDrivingLog(List<File> images) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/createDrivingLog'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      return 'Driving log created: ${responseData.body}';
    } else {
      throw Exception('Failed to create Driving log: ${response.reasonPhrase}');
    }
  }

  Future<String> createOffDutyLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/createOffDutyLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'Off Duty log created: ${response.body}';
    } else {
      throw Exception('Failed to create Off Duty log: ${response.body}');
    }
  }

  Future<String> stopDrivingLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/stopDrivingLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'Driving log stopped: ${response.body}';
    } else {
      throw Exception('Failed to stop Driving log: ${response.body}');
    }
  }

  Future<String> stopOnDutyLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/stopOnDutyLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'On Duty log stopped: ${response.body}';
    } else {
      throw Exception('Failed to stop On Duty log: ${response.body}');
    }
  }

  Future<String> stopOffDutyLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/stopOffDutyLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'Off Duty log stopped: ${response.body}';
    } else {
      throw Exception('Failed to stop Off Duty log: ${response.body}');
    }
  }
}
