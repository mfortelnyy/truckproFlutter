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
  String? _errorMessage;

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
    });

    try {
      await widget.managerApiService.addDriversToCompany(filePath, widget.token);

      setState(() {
        _isLoading = false;
      });
      if (widget.onUpload != null) widget.onUpload!();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "File upload failed: $e";
      });
    }
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
              // Instructions for file upload
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
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Pick Excel File'),
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
