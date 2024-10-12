import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/driver_api_service.dart';
import 'upload_photos_view.dart';

class DriverHomePage extends StatefulWidget {
  final String token;
  
  DriverHomePage({required this.token});
  late DriverApiService driverApiService = DriverApiService(token: token);
    // //decode JWT token to get the role
    // late Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    // late String driverIdStr = decodedToken['userId'];
    // late int driverId = int.parse(driverIdStr);


  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool _isLoading = false;
  

  void _createOnDutyLog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? logId = await widget.driverApiService.createOnDutyLog();
      _showMessage('On-Duty log created: $logId');
    } catch (e) {
      _showMessage('Failed to create on-duty log: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _stopOnDutyLog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? result = await widget.driverApiService.stopOnDutyLog();
      _showMessage('On-Duty log stopped: $result');
    } catch (e) {
      _showMessage('Failed to stop on-duty log: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Driver Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Stop Driving Log'),
              onTap: () {
                _stopOnDutyLog(); 
              },
            ),
            ListTile(
              title: Text('Stop Off-Duty Log'),
              onTap: () {
                
              },
            ),
            ListTile(
              title: Text('Stop On-Duty Log'),
              onTap: () {
                _stopOnDutyLog();
              },
            ),
            ListTile(
              title: Text('Upload Photos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPhotosScreen(
                      token: widget.token,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _createOnDutyLog,
                    child: Text('Start On-Duty Log'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      UploadPhotosScreen(token: widget.token,);
                    },
                    child: Text('Start Driving Log'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                    },
                    child: Text('Start Off-Duty Log'),
                  ),
                ],
              ),
            ),
    );
  }
}
