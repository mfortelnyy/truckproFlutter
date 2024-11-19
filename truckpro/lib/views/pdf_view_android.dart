import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewerWidgetAndroid extends StatefulWidget {
  final Uint8List pdfBytes;

  const PDFViewerWidgetAndroid({super.key, required this.pdfBytes});

  @override
  _PDFViewerWidgetAndroidState createState() => _PDFViewerWidgetAndroidState();
}

class _PDFViewerWidgetAndroidState extends State<PDFViewerWidgetAndroid> {
  late Future<PdfDocument> _pdfDocumentFuture;

  @override
  void initState() {
    super.initState();
    _pdfDocumentFuture = _loadPdfDocument();
  }

  //save the PDF bytes to a file and return the document
  Future<PdfDocument> _loadPdfDocument() async {
    //temporary directory to save the file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_pdf.pdf');

    //store PDF bytes to the file
    await tempFile.writeAsBytes(widget.pdfBytes);

    //load PDF document from the saved file
    return PdfDocument.openFile(tempFile.path);
  }

  //download the PDF to a specific location
  Future<void> _downloadPdf() async {
    final appDir = await getExternalStorageDirectory(); 
    if (appDir == null) return;

    //path to where PDF will be saved
    final filePath = '${appDir.path}/downloaded_pdf.pdf'; 
    final file = File(filePath);

    //save PDF bytes to the file
    await file.writeAsBytes(widget.pdfBytes);

    //display feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfDocument>(
      future: _pdfDocumentFuture,  
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading PDF'));
        } else if (snapshot.hasData) {
          final doc = snapshot.data;  
          if (doc == null) {
            return const Center(child: Text('Failed to load PDF'));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('PDF Viewer'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: PdfView(
                    controller: PdfController(
                      document: Future.value(doc),  
                    ),
                    onDocumentLoaded: (document) {
                      //print('Document loaded successfully!');
                    },
                  ),
                ),
                //donwload button
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
