import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import 'dart:io';
import '../utils/driver_api_service.dart';

class UploadPhotosScreen extends StatefulWidget {
  final String token;
  
  UploadPhotosScreen({required this.token});

  @override
  _UploadPhotosScreenState createState() => _UploadPhotosScreenState(token: token);
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  final String token;
  _UploadPhotosScreenState({required this.token});


  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages.map((image) => File(image.path)).toList();
      });
    }
  }
  Future<void> _createLog() async {
    if (_images.length == 10) {
      DriverApiService driverService = DriverApiService(token: token);
      await driverService.createDrivingLog(_images);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Photos uploaded successfully!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select 10 photos!'),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photos'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Select Photos'),
          ),
          _images.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.file(_images[index]);
                  },
                )
              : Text('No images selected'),
          ElevatedButton(
            onPressed: _createLog, 
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
