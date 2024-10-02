import 'package:flutter/material.dart';
import 'package:truckpro/models/log_entry.dart';

class LogsView extends StatelessWidget {
  final List<dynamic> logs;

  LogsView({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logs[index].logEntryType.toString()),
          );
        },
      ),
    );
  }
}
