import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Image Picker Test"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    const platform = MethodChannel('com.yourapp/image_picker');
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      print("Image Path: $imagePath");
    } on PlatformException catch (e) {
      print("Failed to pick image: '${e.message}'.");
    }
  }
}
