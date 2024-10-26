import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/views/prompt_image.dart';

class DriverApiService {
  //final String _baseUrl = 'https://localhost:443';
  final String _baseUrl = 'https://3cbb-2601-240-cb01-cff0-00-980b.ngrok-free.app';

  final String token;

  DriverApiService({required this.token});

  Future<String>  uploadPhoto(String filePath) async {
    final url = Uri.parse('$_baseUrl/uploadPhoto');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';
    
    
    
    // read the file from the file path and add it as MultipartFile
    var fileBytes = await http.MultipartFile.fromPath('image', filePath);

    request.files.add(fileBytes);

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        return json.decode(responseBody.body)['message'];
      } else {
        throw Exception('Failed to add image: ${responseBody.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  Future<String>  uploadPhotos(List<String> filePaths) async {
    final url = Uri.parse('$_baseUrl/uploadPhotos');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';
    for (String filePath in filePaths) {
      var file = await http.MultipartFile.fromPath(
        'images', 
        filePath,
        filename: basename(filePath),
      );
      request.files.add(file);
    }
    
    // read the file from the file path and add it as MultipartFile
    //var fileBytes = await http.MultipartFile.fromPath('images', filePath);

   //request.files.add(fileBytes);

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        return json.decode(responseBody.body)['message'];
      } else {
        throw Exception('Failed to add image: ${responseBody.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> createOnDutyLog() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/createOnDutyLog'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return 'On Duty log created: ${response.body}';
    } else {
      throw Exception('Failed to create On Duty log: ${response.body}');
    }
  }
  
/*
Future<String> createDrivingLog(List<Map<String, dynamic>> imagesJson) async {
  final url = Uri.parse('$_baseUrl/createDrivingLog');

  var request = http.MultipartRequest('POST', url)
    ..headers['Authorization'] = 'Bearer $token';

  // Extract the images and prompt information from imagesJson
  List<String> filePaths = [];
  

  for (var imageInfo in imagesJson) {
    String filePath = imageInfo['path'];
    filePaths.add(filePath);
    
    var file = await http.MultipartFile.fromPath(
      'images', 
      filePath,
      filename: basename(filePath), 
    );
    request.files.add(file);
  }

  
  String promptImagesJson = jsonEncode(imagesJson);
  request.fields['promptImages'] = promptImagesJson; 

  try {
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      return responseBody.body;
    } else {
      throw Exception('Failed to add image: ${responseBody.body}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
*/

Future<String> createDrivingLog(List<Map<String, dynamic>> imagesJson) async {
  final url = Uri.parse('$_baseUrl/createDrivingLog');
  var request = http.MultipartRequest('POST', url)
    ..headers['Authorization'] = 'Bearer $token';

  // Add images as multipart files
  for (var imageInfo in imagesJson) {
    String filePath = imageInfo['path'];  // file path of the image
    var file = await http.MultipartFile.fromPath(
      'images', 
      filePath,
      filename: basename(filePath),
    );
    request.files.add(file);
  }

  // Encode and send metadata as JSON
  String promptImagesJson = jsonEncode(imagesJson);
  request.fields['promptImages'] = promptImagesJson;

  try {
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      return responseBody.body;
    } else {
      throw Exception('Failed to upload images: ${responseBody.body}');
    }
  } catch (e) {
    throw Exception('Error: $e');
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

  Future<List<LogEntry>> fetchActiveLogs() async { 
    final response = await http.get(
      Uri.parse('$_baseUrl/getActiveLogs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      var jsonList =  jsonDecode(response.body);
      return jsonList.map<LogEntry>((json) => LogEntry.fromJson(json)).toList();
      
    } else {
      throw Exception('Failed to load active logs: ${response.body}');
    }


  }

  Future<List<LogEntry>> fetchAllLogs() async { 
    final response = await http.get(
      Uri.parse('$_baseUrl/getAllLogs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body);
      return jsonList.map<LogEntry>((json) => LogEntry.fromJson(json)).toList();
      
    } else {
      throw Exception('Failed to load logs for driver: ${response.body}');
    }


  }


   Future<String> getTotalOnDutyHoursLastWeek() async { 
    final response = await http.get(
      Uri.parse('$_baseUrl/getTotalOnDutyHoursLastWeek'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    //22:53:11.8922429
    if (response.statusCode == 200) {
      
      return jsonDecode(response.body);
      
    } else {
      throw Exception('Failed to load total on duty hours for driver: ${response.body}');
    }


  }

   Future<String> getTotalDrivingHoursLastWeek() async { 
    final response = await http.get(
      Uri.parse('$_baseUrl/getTotalDrivingHoursLastWeek'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      
      return jsonDecode(response.body);
      
    } else {
      throw Exception('Failed to load total driving hours for driver: ${response.body}');
    }


  }
   
   Future<String> getTotalOffDutyHoursLastWeek() async { 
    final response = await http.get(
      Uri.parse('$_baseUrl/getTotalOffDutyHoursLastWeek'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      
      return jsonDecode(response.body);
      
    } else {
      throw Exception('Failed to load total Off Duty hours for driver: ${response.body}');
    }
  }

   Future<String> notifyManager(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notifyManager'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Message': message,
      },
    );

    if (response.statusCode == 200) {
      
      return jsonDecode(response.body);
      
    } else {
      throw Exception('Failed to notify managers: ${response.body}');
    }

   }

}

basename(String filePath) {
  return filePath.substring(filePath.lastIndexOf('/'));
}
