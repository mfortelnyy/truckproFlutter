import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import 'package:truckpro/utils/manager_api_service.dart';
import '../utils/admin_api_service.dart';
import 'logs_view.dart';

class DriversViewManager extends StatelessWidget {
  final Future<List<User>> driversFuture;  
  final String? companyName;
  final String token;

  const DriversViewManager({
    super.key,
    required this.driversFuture,
    required this.companyName,
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
            return Center(child: Text('No drivers found for company: $companyName'));
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
                    onTap: () async {

                      // fetch logs for this driver
                      var l = await ManagerApiService().getLogsByDriverId(driver.id, token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogsView(logsFuture: Future.value(l), token: token,)),
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
