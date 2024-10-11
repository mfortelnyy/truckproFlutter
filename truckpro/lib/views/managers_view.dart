import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';
import '../utils/admin_api_service.dart';
import 'logs_view.dart';

class ManagersView extends StatefulWidget {
  final Future<List<User>> managersFuture;
  final String token;

  const ManagersView({
    super.key,
    required this.managersFuture,
    required this.token,
  });

  @override
  _ManagersViewState createState() => _ManagersViewState();
}

class _ManagersViewState extends State<ManagersView> {
  late Future<List<User>> managersFuture;

  @override
  void initState() {
    super.initState();
    managersFuture = widget.managersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Managers'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: FutureBuilder<List<User>>(
        future: managersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No managers found!'));
          } else {
            final managers = snapshot.data!;
            return ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) {
                var manager = managers[index];
                return Dismissible(
                  key: Key(manager.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _confirmAndDeleteManager(context, manager.id, index, manager.email);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      title: Text('${manager.firstName} ${manager.lastName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${manager.email}'),
                          Text('Phone: ${manager.phone}'),
                          Text('Role: ${roleToString(manager.role)}'),
                          Text('Email Verified: ${manager.emailVerified ? "Yes" : "No"}'),
                        ],
                      ),
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

 
  void _confirmAndDeleteManager(BuildContext context, int? managerId, int index, String email) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the manager "$email"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteManager(context, managerId, index, email);
    }
  }

  
  void _deleteManager(BuildContext context, int? managerId, int index, String email) async {
    try {
      AdminApiService adminService = AdminApiService();

      var response = await adminService.deleteManager(managerId!, widget.token);

      if (response.contains('Manager deleted successfully!')) {
        setState(() {
          managersFuture = managersFuture.then((managers) {
            managers.removeAt(index); // remove from the list
            return managers;
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manager "$email" deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting manager: $e')),
      );
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
        return "Unknown";
    }
  }
}
