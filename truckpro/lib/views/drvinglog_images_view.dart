import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/log_entry.dart';

class DrivingLogImagesView extends StatelessWidget {
  final Future<List<String>> imageUrls; 
  final LogEntry log;
  final String token;
  final void Function()? onApprove;


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

  const DrivingLogImagesView({
    super.key,
    required this.imageUrls,
    required this.log,
    required this.token,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     appBar: AppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false, // Prevent default back button
      backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      title: Stack(
        children: [
          // Centered title
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Driving Log',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24, // Larger size for the title
                    color: isDarkTheme ? Colors.white70 : Colors.black,
                  ),
                ),
                Text(
                  formatDateTime(log.startTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14, // Smaller size for the date
                    color: isDarkTheme ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Back button positioned at the left
          Positioned(
            left: 10,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ),
        ],
      ),
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
            final groupedImages = _groupImagesByPrompt(urls);

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: promptImages.length,
              itemBuilder: (context, index) {
                final prompt = promptImages[index];
                final images = groupedImages[prompt] ?? [];

                return Card(
                  borderOnForeground: true,
                  surfaceTintColor:  isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                  shadowColor:  isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                                ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2), // prompt color
                          ),
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
                          const Text('No images available for this prompt', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    //ordinal suffix to the day
    String dayWithSuffix = _addOrdinalSuffix(dateTime.day);
    
    //"Nov 17th, 2024"
    DateFormat formatter = DateFormat('MMM dd, yyyy');
    String formattedDate = formatter.format(dateTime);
    
    //replace the day with the one that has the suffix
    return formattedDate.replaceFirst(RegExp(r'\d{2}'), dayWithSuffix);
  }

  String _addOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th'; //cases for 11th, 12th, 13th
    }
    
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

 

  Map<String, List<String>> _groupImagesByPrompt(List<String> urls) {
    final Map<String, List<String>> groupedImages = {};

    for (String url in urls) {
      final parts = url.split('promptId');
      if (parts.length < 2) continue;
      final promptId = int.tryParse(parts[1]) ?? -1;

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
}
