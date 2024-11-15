import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerWidgetAndroid extends StatefulWidget {
  final Uint8List pdfBytes;

  const PDFViewerWidgetAndroid({super.key, required this.pdfBytes});

  @override
  _PDFViewerWidgetAndroidState createState() => _PDFViewerWidgetAndroidState();
}

class _PDFViewerWidgetAndroidState extends State<PDFViewerWidgetAndroid> {
  late Future<PDFDocument> _pdfDocumentFuture;

  @override
  void initState() {
    super.initState();
    _pdfDocumentFuture = _loadPdfDocument();
  }

  // Function to save the PDF bytes to a file and return the document
  Future<PDFDocument> _loadPdfDocument() async {
    // Get the temporary directory to save the file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_pdf.pdf');

    // Save the PDF bytes to the file
    await tempFile.writeAsBytes(widget.pdfBytes);

    // Load the PDF document from the saved file
    return PDFDocument.fromFile(tempFile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PDFDocument>(
      future: _pdfDocumentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading PDF'));
        } else if (snapshot.hasData) {
          final doc = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: const Text('PDF Viewer'),
            ),
            body: PDFViewer(
              document: doc!,
            ),
          );
        } else {
          return const Center(child: Text('No PDF data found'));
        }
      },
    );
  }
}
