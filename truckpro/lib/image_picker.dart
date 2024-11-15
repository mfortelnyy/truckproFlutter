import 'package:flutter/services.dart';

class NativeImagePicker {
  static const MethodChannel _channel = MethodChannel('com.example.truckpro/image_picker');

  //picks an image from either the camera or the gallery
  static Future<String?> pickImage() async {
    final String? imagePath = await _channel.invokeMethod('pickImage');
    print(imagePath);
    return imagePath;
  }
}
