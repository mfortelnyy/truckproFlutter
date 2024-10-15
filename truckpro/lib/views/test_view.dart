
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truckpro/utils/driver_api_service.dart';

class ImagePickerTestScreen extends StatefulWidget {
  final DriverApiService driverApiService;

  const ImagePickerTestScreen({super.key, required this.driverApiService});

  @override
  _ImagePickerTestScreenState createState() => _ImagePickerTestScreenState();
}

class _ImagePickerTestScreenState extends State<ImagePickerTestScreen> {
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
        allowedExtensions: ['png', 'jpg', 'jpeg', 'heic', 'heics' ], // only images
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          _fileName = file.name;
        });

        // Upload the image using the path
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
     
      var res = await widget.driverApiService.uploadPhoto(filePath);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "File upload failed: $e ";
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fileName != null) Text('Selected file: $_fileName'),
            if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick Excel File'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
