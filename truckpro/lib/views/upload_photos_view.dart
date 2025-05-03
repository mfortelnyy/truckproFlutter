import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trucksnap/utils/driver_api_service.dart';

import '../image_picker.dart';
import 'prompt_image.dart';

class UploadPhotosScreen extends StatefulWidget {
  final String token;
  final Future<void> Function() onPhotoUpload;
 
  UploadPhotosScreen({
    Key? key,
    required this.token,
    required this.onPhotoUpload,
  }) : super(key: key);

  late final DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _UploadPhotosScreenState createState() => _UploadPhotosScreenState(token: token);
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final String token;
  bool isUploading = false; // Track upload status

  Map<String, List<PromptImage>> promptImages = {
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

  /// Opens the image picker and adds the picked image for the given prompt.
  Future<void> _pickImages(String prompt, int promptIndex, int maxImages) async {
    try {
      // Pick an image using your platform-specific image picker.
      final String? imagePath = await ImagePickerManager.pickImage();
      if (imagePath != null && promptImages[prompt]!.length < maxImages) {
        setState(() {
          promptImages[prompt]!.add(PromptImage(imagePath, promptIndex));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only upload up to $maxImages image(s) for this prompt!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while picking the file: $e')),
      );
    }
  }

  /// Submits the uploaded photos.
  /// This method now calls a new API endpoint (e.g. `uploadDailyTruckPhotos`) that you should implement on the backend.
  Future<void> _submitPhotos() async {
    setState(() {
      isUploading = true;
    });

    bool allImagesUploaded = true;
    List<Map<String, dynamic>> imagesJson = [];

    // Check that each prompt has at least one image.
    promptImages.forEach((prompt, imagesList) {
      if (imagesList.isEmpty) {
        allImagesUploaded = false;
      }
      imagesJson.addAll(imagesList.map((img) => img.toJson()));
    });

    if (allImagesUploaded) {
      try {
        await widget.driverApiService.uploadDailyTruckPhotos(imagesJson);
        // Call any callbacks needed to refresh your home screen state.
        await widget.onPhotoUpload();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photos uploaded successfully! Await manager approval.'),
            backgroundColor: Color.fromARGB(219, 79, 194, 70),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during upload: $e'),
            backgroundColor: const Color.fromARGB(230, 247, 42, 66),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required photos!'),
          backgroundColor: Color.fromARGB(230, 247, 42, 66),
        ),
      );
    }

    setState(() {
      isUploading = false;
    });
  }

  /// Returns the maximum number of images allowed for a given prompt.
  int _getMaxImagesForPrompt(String prompt) {
    if (prompt.contains('(3 pictures)')) {
      return 3;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Daily Truck Photos'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: ListView(
        children: promptImages.keys.toList().asMap().entries.map((entry) {
          int promptIndex = entry.key;
          String prompt = entry.value;
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
                    trailing: Text('Max $maxImages photo(s)'),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () => _pickImages(prompt, promptIndex, maxImages),
                      child: const Text('Select Photo'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  promptImages[prompt]!.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          children: promptImages[prompt]!.map((image) {
                            return Stack(
                              children: [
                                Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        promptImages[prompt]!.remove(image);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(left: 20.0, bottom: 10),
                          child: Text('No image selected'),
                        ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: isUploading
          ? const CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: isUploading ? null : _submitPhotos,
              child: const Icon(Icons.upload),
            ),
    );
  }
}