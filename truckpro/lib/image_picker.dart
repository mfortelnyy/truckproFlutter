import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerManager {
  //MethodChannel for iOS native code
  static const MethodChannel _iosChannel = MethodChannel('com.truckpro.appdev/image_picker');
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<String?> pickImage({bool fromCamera = false}) async {
    if (Platform.isIOS) {
      // For iOS picks an image from either the camera or the gallery
      try {
        final String? imagePath = await _iosChannel.invokeMethod(
          'pickImage',
          {'source': fromCamera ? 'camera' : 'gallery'},
        );
        return imagePath;
      } catch (e) {
        print('Error picking image on iOS: $e');
        return null;
      }
    } else if (Platform.isAndroid) {
      //android use the image_picker plugin directly
      try {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        );
        return pickedFile?.path; 
      } catch (e) {
        print('Error picking image on Android: $e');
        return null;
      }
    }
    return null;
  }
}
