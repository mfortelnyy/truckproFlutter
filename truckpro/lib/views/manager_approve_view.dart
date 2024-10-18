

import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/utils/manager_api_service.dart';

class ManagerApproveView extends StatelessWidget {
  final Future<List<String>> imageUrls; 
  final LogEntry log;
  final String token;

   static const List<String> promptImages = [
  'Front truck side with Head lights + Emergency flashers and marker lights ON',
  'With open hood left side of engine',
  'Truck Left steer axle tire condition and PSI measurements, brakes condition (3 pictures)',
  'Truck: 6-way electric socket, green, blue, red hoses condition',
  'Truck 1st Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Truck 2nd Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Truck Left Mudflap',
  'Trailer: 6-way electric socket, green, blue, red hoses condition',
  'Trailer left middle turn signal condition',
  'Trailer 1st Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Trailer 2nd Left axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Trailer Left Mudflap',
  'Trailer rear end with emergency flashers ON, marker lights ON, turn lights condition, brake lights condition, DOT bumper condition, license plate (door condition, door latch condition, 8-hinges, load securement)',
  'Trailer Right Mudflap',
  'Trailer 2nd Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Trailer 1st Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pictures)',
  'Trailer right middle turn signal condition',
  'Truck right Mudflap',
  'Truck 2nd right axle outside & inside tire condition and PSI measurements, brakes condition(3 pics)',
  'Truck 1st Right axle outside & inside tire condition and PSI measurements, brakes condition(3 pics)',
  'Truck Right steer axle tire condition and PSI measurements, brakes condition(3 pics)',
  'With open hood right side of engine',
];

  

  const ManagerApproveView({
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
            // Group images by prompt
            final groupedImages = _groupImagesByPrompt(urls);

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: promptImages.length,
              itemBuilder: (context, index) {
                final prompt = promptImages[index];
                final images = groupedImages[prompt] ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (images.isNotEmpty) 
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              return InkWell(
                                onTap: () {
                                  _showImageDialog(context, images[imgIndex]);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    images[imgIndex],
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
                          )
                        else
                          const Text('No images available for this prompt'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: log.isApprovedByManager ? null : FloatingActionButton(
        onPressed: () async {
          await _approveLog(log.id, context);
        },
        child: const Icon(Icons.check),
        tooltip: 'Approve Log',
      ),
    );
  }

  Map<String, List<String>> _groupImagesByPrompt(List<String> urls) {
    final Map<String, List<String>> groupedImages = {};

    for (String url in urls) {
      // Extract promptId from the URL (assuming it's the last part of the URL)
      final parts = url.split('promptId');
      if (parts.length < 2) continue; // skip if the format is incorrect
      final promptId = int.tryParse(parts[1]) ?? -1;

      // Use promptId to map to the correct prompt in promptImages
      if (promptId >= 0 && promptId < promptImages.length) {
        final prompt = promptImages[promptId];
        groupedImages.putIfAbsent(prompt, () => []).add(url);
      }
    }

    return groupedImages;
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
