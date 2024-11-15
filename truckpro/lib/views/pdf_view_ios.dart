import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerWidgetIos extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFViewerWidgetIos({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return PDFView(
      pdfData: pdfBytes, 
    );
  }
}
