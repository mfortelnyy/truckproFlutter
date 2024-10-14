import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:truckpro/utils/driver_api_service.dart';

class UploadPhotosScreen extends StatefulWidget {
  final String token;

  UploadPhotosScreen({required this.token});
  late DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _UploadPhotosScreenState createState() => _UploadPhotosScreenState(token: token);
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final String token;

  // Each prompt has a set number of images that need to be uploaded
  Map<String, List<File>> promptImages = {
    'Front truck side with Head lights + Emergency flashers and marker lights ON': [],
    'With open hood left side of engine': [],
    'Truck Left steer axle tire condition and PSI measurements, brakes condition (3 pictures)': [],
    'Truck: 6-way electric socket, green, blue, red hoses condition': [],
    'Truck 1st Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Truck 2nd Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Truck Left Mudflap': [],
    'Trailer: 6-way electric socket, green,blue,red hoses condition': [],
    'Trailer left middle turn signal condition': [],
    'Trailer 1st Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Trailer 2nd Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Trailer Left Mudflap': [],
    'Trailer rear end with emergency flashers ON, marker lights ON, turn lights condition, brake lights condition, DOT bumper condition, license plate (door condition, door latch condition, 8-hinges, load securement)': [],
    'Trailer Right Mudflap': [],
    'Trailer 2nd Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Trailer 1st Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)': [],
    'Trailer right middle turn signal condition': [],
    'Truck right Mudflap': [],
    'Truck 2nd right axle outside & inside tire condition and PSI measurements, brakes condition(3 pics)': [],
    'Truck 1st Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pics)': [],
    'Truck Right steer axle tire condition and PSI measurements, brakes condition(3 pics)': [],
    'With open hood right side of engine': [],
  };

  _UploadPhotosScreenState({required this.token});

  // Pick image for a specific prompt
  Future<void> _pickImages(String prompt, int maxImages) async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.length <= maxImages) {
      setState(() {
        promptImages[prompt] = selectedImages.map((image) => File(image.path)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only upload up to $maxImages images for this prompt!'),
        ),
      );
    }
  }

  
  Future<void> _submitLog() async {
    bool allImagesUploaded = true;
    List<File> images = [];
    promptImages.forEach((key, value) {
      if (value.isEmpty) {
        allImagesUploaded = false;
      }
      for (var file in value) {
        images.add(file);
      }
      
       
    });

    if (allImagesUploaded) {
      widget.driverApiService.createDrivingLog(images);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Photos uploaded successfully!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please upload all required photos!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photos'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: ListView(
        children: promptImages.keys.map((prompt) {
          // Decide how many images are required for each prompt
          int maxImages = _getMaxImagesForPrompt(prompt);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(prompt),
                    subtitle: Text('Max $maxImages photos'),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImages(prompt, maxImages),
                    child: Text('Select Photos'),
                  ),
                  SizedBox(height: 10),
                  // Display the selected images
                  promptImages[prompt]!.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          children: promptImages[prompt]!.map((image) {
                            return Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }).toList(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No images selected'),
                        ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitLog,
        child: Icon(Icons.upload),
      ),
    );
  }

  // A helper function to determine how many images are needed per prompt
  int _getMaxImagesForPrompt(String prompt) {
    if (prompt.contains('(3 pictures)')) {
      return 3;
    } else if (prompt.contains('(1picture)')) {
      return 1;
    } else if (prompt.contains('(door condition')) {
      return 3; // Assuming multiple images are needed
    }
    return 1;
  }
}
