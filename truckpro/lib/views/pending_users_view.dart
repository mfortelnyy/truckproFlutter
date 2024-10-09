import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/pending_user.dart';
import 'package:truckpro/utils/manager_api_service.dart';

class PendingUsersView extends StatefulWidget {
  final Future<List<PendingUser>> pendingUsersFuture;
  final String token;
  final bool sendEmail;

  const PendingUsersView({
    super.key,
    required this.pendingUsersFuture,
    required this.token,
    required this.sendEmail,
  });

  @override
  _PendingUsersViewState createState() => _PendingUsersViewState();
}

class _PendingUsersViewState extends State<PendingUsersView> {
  List<PendingUser> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    widget.pendingUsersFuture.then((users) {
      setState(() {
        pendingUsers = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Drivers'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: Column(
        children: [
          Expanded(
            child: pendingUsers.isEmpty
                ? const Center(child: Text('No drivers found for company!'))
                : ListView.builder(
                    itemCount: pendingUsers.length,
                    itemBuilder: (context, index) {
                      var pUser = pendingUsers[index];
                      return Dismissible(
                        key: Key(pUser.id.toString()), 
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deletePendingUser(pUser.id, index);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text('User with id: ${pUser.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${pUser.email}'),
                                Text('Date Created: ${formatDateTime(pUser.createdDate)}'),
                                Text('Company Id: ${pUser.companyId}'),
                                Text('Invitation Sent: ${boolToString(pUser.invitationSent)}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.sendEmail)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sendEmailToPendingUsers(widget.token, context);
                  },
                  child: const Text('Send Email to All Pending Users'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deletePendingUser(int userId, int index) async {
    try {
      ManagerApiService managerService = ManagerApiService();
      
      String res = await managerService.deletePendingUser(widget.token, userId);
      
      if (res.isNotEmpty) {
        setState(() {
          pendingUsers.removeAt(index); 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pending User with ID $userId deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  Future<void> _sendEmailToPendingUsers(String token, BuildContext context) async {
    try {
      ManagerApiService managerService = ManagerApiService();
      String res = await managerService.sendEmailToPendingUsers(token);

      if (res.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emails sent successfully: $res')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No response from the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending emails: $e')),
      );
    }
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    return formatter.format(dateTime);
  }

  String boolToString(bool val) {
    return val ? "Yes" : "No";
  }
}
