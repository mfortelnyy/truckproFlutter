import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import 'package:truckpro/utils/manager_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'logs_view.dart';

class DriversViewManager extends StatelessWidget {
  final Future<List<User>> driversFuture;  
  final String token;

  const DriversViewManager({
    super.key,
    required this.driversFuture,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers'), backgroundColor: const Color.fromARGB(255, 241, 158, 89),),
      body: FutureBuilder<List<User>>(
        future: driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No drivers registered from pending!'));
          } else {
            final drivers = snapshot.data!;
            return ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                var driver = drivers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    title: Text('${driver.firstName} ${driver.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${driver.email}'),
                        Text('Phone: ${driver.phone}'),
                        Text('Role: ${roleToString(driver.role)}'),
                        Text('Email Verified: ${driver.emailVerified ? "Yes" : "No"}'),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                                icon: Icon(Icons.phone),
                                label: Text('Call'),
                                onPressed: () {
                                  _makePhoneCall(driver.phone);  
                                },
                              ) ,
                    onTap: () async {

                      // fetch logs for this driver
                      var l = await ManagerApiService().getLogsByDriverId(driver.id, token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogsView(logsFuture: Future.value(l), token: token, approve: true,)),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}

roleToString(int role) {
  switch (role) {
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
