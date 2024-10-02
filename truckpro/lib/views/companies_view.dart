import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';

class CompaniesView extends StatelessWidget {
  final Future<List<Company>> companiesFuture;
  

  const CompaniesView({super.key, required this.companiesFuture, required String token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Companies')),
      body: FutureBuilder<List<dynamic>>(
        future: companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          } else {
            final companies = snapshot.data!;
            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                var company = companies[index];
                return ListTile(
                  title: Text(company.name),
                  subtitle: Text('ID: ${company.id}'),
                  );
              },
            );
          }
        },
      ),
    );
  }
}
