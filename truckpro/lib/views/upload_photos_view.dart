import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:truckpro/utils/driver_api_service.dart';

class UploadPhotosScreen extends StatefulWidget {
  final String token;
  Future<void> Function() onPhotoUpload;
  Future<void> Function() resetOffDuty;
 

  UploadPhotosScreen({super.key, required this.token, required this.onPhotoUpload, required this.resetOffDuty});
  late DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _UploadPhotosScreenState createState() => _UploadPhotosScreenState(token: token);
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final String token;

  Map<String, List<String>> promptImages = {
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

  // pick images for a specific prompt using FilePicker
  Future<void> _pickImages(String prompt, int maxImages) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'heic', 'heics'], // only images
      allowMultiple: true, 
    );

    if (result != null && result.files.length + promptImages[prompt]!.length <= maxImages) {
      setState(() {
        // append new file paths to the existing list
        promptImages[prompt]!.addAll(result.files.map((file) => file.path!).toList());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only upload up to $maxImages images for this prompt!'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error while picking the file: $e'),
      ),
    );
  }
}


  Future<void> _submitLog() async {
    bool allImagesUploaded = true;
    List<String> images = []; // change to list of strings
    promptImages.forEach((key, value) {
      if (value.isEmpty) {
        allImagesUploaded = true;
      }
      images.addAll(value); // add file paths to the list
    });

    if (allImagesUploaded) {
      await widget.driverApiService.createDrivingLog(images);
      widget.onPhotoUpload();
      widget.resetOffDuty();
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Photos uploaded successfully! \nDriving Log started!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please upload all required photos!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: ListView(
        children: promptImages.keys.map((prompt) {
          //get how many images are required for each prompt
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
                    child: const Text('Select Photos'),
                  ),
                  const SizedBox(height: 10),
                  // disp the selected images using the file path
                  promptImages[prompt]!.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          children: promptImages[prompt]!.map((path) {
                            return Image.file(
                              File(path), // convert path back to File for display
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }).toList(),
                        )
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
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
        child: const Icon(Icons.upload),
      ),
    );
  }

  // function to determine how many images are needed per prompt
  int _getMaxImagesForPrompt(String prompt) {
    if (prompt.contains('(3 pictures)')) {
      return 3;
    } else if (prompt.contains('(1 picture)')) {
      return 1;
    } else {
      return 1; 
    }
  }
}
