import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerWidgetAndroid extends StatefulWidget {
  final Uint8List pdfBytes;

  const PDFViewerWidgetAndroid({super.key, required this.pdfBytes});

  @override
  _PDFViewerWidgetAndroidState createState() => _PDFViewerWidgetAndroidState();
}

class _PDFViewerWidgetAndroidState extends State<PDFViewerWidgetAndroid> {
  late Future<File> _pdfFileFuture;

  @override
  void initState() {
    super.initState();
    _pdfFileFuture = _savePdfFile();
  }

  Future<File> _savePdfFile() async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_pdf.pdf');

    await tempFile.writeAsBytes(widget.pdfBytes);

    return tempFile;
  }

  Future<void> _downloadPdf() async {
    final appDir = await getExternalStorageDirectory();
    if (appDir == null) return;

    final filePath = '${appDir.path}/downloaded_pdf.pdf';
    final file = File(filePath);

    await file.writeAsBytes(widget.pdfBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _pdfFileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading PDF'));
        } else if (snapshot.hasData) {
          final file = snapshot.data;
          if (file == null) {
            return const Center(child: Text('Failed to load PDF'));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('PDF Viewer'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: file.path,  
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _downloadPdf,
                    child: const Text('Download PDF'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No PDF data found'));
        }
      },
    );
  }
}
