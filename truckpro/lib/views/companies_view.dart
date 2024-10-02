import 'package:flutter/material.dart';

class CompaniesView extends StatelessWidget {
  final List<dynamic> companies;
  

  const CompaniesView({super.key, required this.companies, required String token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Companies')),
      body: ListView.builder(
        itemCount: companies.length,
        itemBuilder: (context, index) {
          var company = companies[index];
          return ListTile(
            title: Text(company['name']),
            subtitle: Text('ID: ${company['id']}'),
          );
        },
      ),
    );
  }
}
