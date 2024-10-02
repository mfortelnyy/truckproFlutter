import 'package:flutter/material.dart';
import '../utils/admin_api_service.dart';
import '../models/log_entry.dart';
import 'logs_view.dart';

class DriversView extends StatelessWidget {
  final List<dynamic> drivers;
  final AdminApiService adminService;
  final String token;

  const DriversView({super.key, required this.drivers, required this.adminService, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          var driver = drivers[index];
          return ListTile(
            title: Text(driver['name']),
            onTap: () async {
              // fetch logs for this driver
              List<LogEntry> logs = await AdminApiService().getLogsByDriverId(driver['id']);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogsView(logs: logs)),
              );
            },
          );
        },
      ),
    );
  }
}
