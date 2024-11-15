import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Import platform-specific PDF viewer widgets
import 'pdf_view_android.dart';
import 'pdf_view_ios.dart';

class PDFViewerWidget extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFViewerWidget({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // Use the iOS-specific PDF viewer
      return PDFViewerWidgetIos(pdfBytes: pdfBytes);
    } else if (Platform.isAndroid) {
      // Use the Android-specific PDF viewer
      return PDFViewerWidgetAndroid(pdfBytes: pdfBytes);
    } else {
      // Fallback or handle other platforms
      return Center(child: Text('Unsupported platform'));
    }
  }
}
