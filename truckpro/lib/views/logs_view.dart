import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/models/userDto.dart';
import 'package:truckpro/utils/manager_api_service.dart';
import 'package:truckpro/views/manager_approve_view.dart';
import 'package:url_launcher/url_launcher.dart';



import 'drvinglog_images_view.dart';

class LogsView extends StatelessWidget {
  final Future<List<LogEntry>> logsFuture;  
  final String token;
  final bool approve;
  final void Function()? onApprove;
  final UserDto? userDto;
  

  const LogsView({super.key, required this.logsFuture, required this.token, required this.approve, this.userDto, this.onApprove});

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
            return const Center(child: Text('No logs found'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          } else {
            final logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                var log = logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: Column(
                    children: [
                      ListTile(
                        title: onApprove != null 
                        ? Text( "${LogEntryType.values[log.logEntryType].toString().split(".")[1]} Log by ${log.user!.firstName} ${log.user!.lastName} ",
                          style: const TextStyle(fontWeight: FontWeight.w600)
                          )
                        : Text( "${LogEntryType.values[log.logEntryType].toString().split(".")[1]} Log by ${userDto!.firstName} ${userDto!.lastName} ",
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: log.logEntryType == 0
                            ? _buildDrivingLogInfo(log)
                            : _buildNonDrivingLogInfo(log),
                        trailing: Column(
                                    children: [ 
                                      onApprove != null 
                                        ? Text('${log.user?.email} ',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)
                                            )
                                        :   Text('${userDto?.email} ',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)
                                            ),
                                          ],
                                        ),
                        onTap: approve ? () async {
                          if (log.logEntryType == 0) {
                            // if driving log and manager => display images for approval 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManagerApproveView(
                                  imageUrls: Future.value(log.imageUrls),
                                  log: log,
                                  token: token,
                                  onApprove: onApprove, 
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This is not a driving log!')),
                            );
                          }
                        } : () async {
                          if (log.logEntryType == 0) {
                            // if driving log => display images 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DrivingLogImagesView(
                                  imageUrls: Future.value(log.imageUrls),
                                  log: log,
                                  token: token, 
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This is not a driving log!')),
                            );
                          }
                        } ,
                      ),
                      
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  
  Widget _buildDrivingLogInfo(LogEntry log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //const Text('Driving Log'),
        Text('Log Start Date: ${formatDateTime(log.startTime)}'),
        log.endTime != null
            ? Text('Log End Date: ${formatDateTime(log.endTime!)}')
            : const Text('Log In Progress'),
        Text('Approved By Manager: ${boolToString(log.isApprovedByManager)}'),
        Text('Images attached: ${log.imageUrls?.length ?? 0}'),
        
      ],
      
    );
  }

  
  Widget _buildNonDrivingLogInfo(LogEntry log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //const Text('Non-Driving Log'),
        Text('Log Start Date: ${formatDateTime(log.startTime)}'),
        log.endTime != null
            ? Text('Log End Date: ${formatDateTime(log.endTime!)}')
            : const Text('In Progress', style: TextStyle(fontSize: 14)),
        ],
    );
  }

  String roleToString(int role) {
    switch (role) 
    {
      case 0:
        return "Admin";
      case 1:
        return "Manager";
      case 2:
        return "Driver";
      default:
        return "default";
    }
  }

  String boolToString(bool val) {
    return val ? "Yes" : "No";
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    return formatter.format(dateTime);
  }
}
