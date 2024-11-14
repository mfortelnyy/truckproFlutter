import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import 'package:truckpro/utils/manager_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'logs_view.dart';

class DriversViewManager extends StatefulWidget {
  final Future<List<User>> driversFuture;
  final String token;

  const DriversViewManager({
    super.key,
    required this.driversFuture,
    required this.token,
  });

  @override
  _DriversViewManagerState createState() => _DriversViewManagerState();
}

class _DriversViewManagerState extends State<DriversViewManager> {
  List<User> allDrivers = [];
  List<User> filteredDrivers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.driversFuture.then((drivers) {
      setState(() {
        allDrivers = drivers;
        filteredDrivers = drivers;
      });
    });
  }

  void _filterDrivers(String query) {
    final filtered = allDrivers.where((driver) {
      final fullName = '${driver.firstName} ${driver.lastName}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchQuery = query;
      filteredDrivers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterDrivers,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredDrivers.isEmpty
          ? const Center(child: Text('No drivers registered from pending!'))
          : ListView.builder(
              itemCount: filteredDrivers.length,
              itemBuilder: (context, index) {
                var driver = filteredDrivers[index];
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
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      onPressed: () {
                        _makePhoneCall(driver.phone);
                      },
                    ),
                    onTap: () async {
                      var logs = await ManagerApiService().getLogsByDriverId(driver.id, widget.token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsView(
                            logsFuture: Future.value(logs),
                            token: widget.token,
                            approve: true,
                            driverId: driver.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
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

String roleToString(int role) {
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
