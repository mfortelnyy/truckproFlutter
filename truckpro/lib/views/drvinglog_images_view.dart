import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/utils/manager_api_service.dart';

class DrivingLogImagesView extends StatelessWidget {
  final Future<List<String>> imageUrls;
  final LogEntry log;
  final String token;
  

  const DrivingLogImagesView({
    super.key,
    required this.imageUrls,
    required this.log,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driving Log Images'),
      ),
      body: FutureBuilder<List<String>>(
        future: imageUrls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images available'));
          } else {
            final urls = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // number of images per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: urls.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _showImageDialog(context, urls[index]);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            urls[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!log.isApprovedByManager)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _approveLog(log.id, context);
                      },
                      child: const Text('Approve Log'),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Future<void> _approveLog(int logId, BuildContext context) async {
    try {
      ManagerApiService managerApiService = ManagerApiService();
      final response = await managerApiService.approveDrivingLogById(logId, token);
      print("response from approving log $response");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log approved successfully!')),
      );
      Navigator.of(context).pop(); 
        } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
