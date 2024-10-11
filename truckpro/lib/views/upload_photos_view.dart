import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadPhotosScreen extends StatefulWidget {
  final Function(List<File>) callback; 

  UploadPhotosScreen({required this.callback});

  @override
  _UploadPhotosScreenState createState() => _UploadPhotosScreenState();
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages =
            pickedFiles.take(10).map((e) => File(e.path)).toList();
      });
    }
  }

  void _submit() {
    if (_selectedImages.length > 0) {
      widget.callback(_selectedImages); 
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one image.')),
      );
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
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Image.file(
                  _selectedImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Select Images'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Upload Selected Photos'),
          ),
        ],
      ),
    );
  }
}
