import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truckpro/utils/manager_api_service.dart';

class UploadDriversScreen extends StatefulWidget {
  final String token;
  final ManagerApiService managerApiService;
  final VoidCallback? onUpload;

  const UploadDriversScreen({
    super.key,
    required this.managerApiService,
    required this.token,
    this.onUpload,
  });

  @override
  _UploadDriversScreenState createState() => _UploadDriversScreenState();
}

class _UploadDriversScreenState extends State<UploadDriversScreen> {
  String? _fileName;
  bool _isLoading = false;
  bool _isButtonDisabled = false;
  String? _errorMessage;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'], // only Excel files
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          _fileName = file.name;
        });

        // Upload the file using the path
        _uploadFile(file.path!);
      } else {
        setState(() {
          _errorMessage = "No file selected";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error while picking the file: $e";
      });
    }
  }

  Future<void> _uploadFile(String filePath) async {
    setState(() {
      _isLoading = true;
      _isButtonDisabled = true;
      _startCooldown();
    });

    try {
      var res = await widget.managerApiService.addDriversToCompany(filePath, widget.token);

      setState(() {
        _isLoading = false;
        _isButtonDisabled = false; // Enable button immediately if successful
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.contains('successfully')
              ? 'File uploaded successfully!'
              : 'File upload failed!\n${res.split("Error: ").last}'),
          backgroundColor: res.contains('successfully')
              ? Color.fromARGB(241, 106, 242, 97)
              : Color.fromARGB(230, 247, 42, 66),
        ),
      );

      if (widget.onUpload != null) widget.onUpload!();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "File upload failed: $e";
      });
    }
  }

  void _startCooldown() {
    _cooldownSeconds = 30;
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
      });

      if (_cooldownSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Driver Emails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please select an Excel file containing the driver emails to upload. \nemails\ne1@example.com\ne2@example.com\n...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_fileName != null) Text('Selected file: $_fileName'),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonDisabled ? null : _pickFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(_isButtonDisabled
                    ? 'Wait $_cooldownSeconds seconds'
                    : 'Pick Excel File'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
