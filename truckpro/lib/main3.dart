import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Image Picker and Shared Preferences"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    const platform = MethodChannel('com.truckpro.appdev/image_picker');
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      if (imagePath != null) {
        print("Image Path: $imagePath");

        // Save the image path in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedImagePath', imagePath);

        // Retrieve and print to confirm
        String? savedPath = prefs.getString('savedImagePath');
        print("Saved Image Path in Shared Preferences: $savedPath");
      } else {
        print("No image selected.");
      }
    } on PlatformException catch (e) {
      print("Failed to pick image: '${e.message}'.");
    }
  }
}
