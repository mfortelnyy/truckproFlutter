import 'package:flutter/material.dart';
import 'package:truckpro/models/pending_user.dart';
import '../utils/admin_api_service.dart';
import 'logs_view.dart';

class PendingUsersView extends StatelessWidget {
  
  final Future<List<PendingUser>> pendingUsersFuture;  
  final String token;

  const PendingUsersView({
    super.key,
    required this.pendingUsersFuture,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers'), backgroundColor: Color.fromARGB(255, 241, 158, 89),),
      body: FutureBuilder<List<PendingUser>>(
        future: pendingUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No drivers found for company!'));
          } else {
            final pendingUsers = snapshot.data!;
            return ListView.builder(
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                var pUser = pendingUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    title: Text('User with id: ${pUser.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${pUser.email}'),
                        Text('Date Created: ${pUser.createdDate}'),
                        Text('Company Id: ${pUser.companyId}'),
                        Text('Invitation Sent: ${pUser.invitationSent ? "Yes" : "No"}'),
                      ],
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
