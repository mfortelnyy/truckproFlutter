import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';

class LogsView extends StatelessWidget {
  final Future<List<LogEntry>> logsFuture;  

  const LogsView({super.key, required this.logsFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: FutureBuilder<List<dynamic>>(
        future: logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          } else {
            final logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                var log = logs[index];
                return ListTile(
                  title: Text('Log Entry Type: ${log['logEntryType']}'),
                  subtitle: Text('Start Time: ${log['startTime']}'), 
                );
              },
            );
          }
        },
      ),
    );
  }
}
