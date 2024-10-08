import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';
import 'package:truckpro/utils/admin_api_service.dart';

import 'drivers_view.dart';

class CompaniesView extends StatelessWidget {
  final Future<List<Company>> companiesFuture;
  final String token;

  const CompaniesView({super.key, required this.companiesFuture, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Companies',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
        elevation: 0, // Remove shadow
      ),
      body: Container(
        color: Colors.white, 
        child: FutureBuilder<List<Company>>(
          future: companiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No companies found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else {
              final companies = snapshot.data!;
              return ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  var company = companies[index];
                  return Card( 
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4, 
                    child: ListTile(
                      title: Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${company.id}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      contentPadding: const EdgeInsets.all(16), 
                      onTap: () {
                        // Navigate to DriversView, passing the company ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriversView(
                              driversFuture: AdminApiService().getDriversByCompanyId(company.id, token),
                              companyName: company.name, adminService: AdminApiService(), token:token,
                            ),
                          ),
                        );
                      },
                    ),
                    
                  );
                },
                
              );
            }
          },
        ),
      ),
    );
  }
}
