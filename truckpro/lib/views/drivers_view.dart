import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import '../utils/admin_api_service.dart';
import 'logs_view.dart';

class DriversView extends StatelessWidget {
  final AdminApiService adminService;
  final Future<List<User>> driversFuture;  

  const DriversView({super.key, required this.adminService, required this.driversFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: FutureBuilder<List<User>>(
        future: driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          } else {
            final drivers = snapshot.data!;
            return ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                var driver = drivers[index];
                return ListTile(
                    title: Text(driver.firstName),
                    subtitle: Text(driver.email),
                    onTap: () async {
                      // fetch logs for this driver
                      var logs =  adminService.getLogsByDriverId(driver.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogsView(logsFuture: logs)),
                      );
                    },
                );
              }
            );
          }
        },
      ),
    );
  }
}
