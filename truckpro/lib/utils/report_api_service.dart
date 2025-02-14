import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:truckpro/models/log_entry_type.dart';

class ReportApiService 
{
  final String baseUrl = 'https://truckcheck.org';

  Future<Uint8List?> generatePDF(DateTime startDate, DateTime endDate, String token, int driverId, List<LogEntryType> selectedLogTypes) async {
    // format the dates to match the expected format in the backend
    String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    String endDateString = DateFormat('yyyy-MM-dd').format(endDate);
    // serialize the selectedLogTypes list to a JSON string
    String selectedLogTypesString = jsonEncode(selectedLogTypes.map((e) => e.toString().split(".").last).toList());


    final url = Uri.parse('$baseUrl/getdrivingRecordsPDF?startDate=$startDateString&endDate=$endDateString&driverId=$driverId&selectedLogTypesJsonString=$selectedLogTypesString');

    final headers = {
      'Authorization': 'Bearer $token',  
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        //return the PDF file as raw bytes
        return response.bodyBytes;
      } else {
        // print('Failed to generate PDF. Status code: ${response.statusCode}');
        // print('Error message: ${response.body}');
        return null;
      }
    } catch (e) {
      //print('Error occurred while generating PDF: $e');
      return null;
    }
  }
  
}