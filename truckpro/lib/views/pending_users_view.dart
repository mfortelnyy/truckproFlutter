import 'package:flutter/material.dart';
import '../models/pending_user.dart';

class PendingUsersView extends StatelessWidget {
  final List<PendingUser> pendingUsers;

  const PendingUsersView({super.key, required this.pendingUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pendingUsers.isNotEmpty
            ? ListView.builder(
                itemCount: pendingUsers.length,
                itemBuilder: (context, index) {
                  final pendingUser = pendingUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(pendingUser.email),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Created: ${pendingUser.createdDate.toLocal()}'),
                          Text('Company ID: ${pendingUser.companyId}'),
                          Text('Invitation Sent: ${pendingUser.invitationSent ? "Yes" : "No"}'),
                        ],
                      ),
                      trailing: pendingUser.invitationSent
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              )
            : const Center(
                child: Text('No pending users found.'),
              ),
      ),
    );
  }
}
