import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:truckpro/models/company.dart';
import 'package:truckpro/utils/admin_api_service.dart';
import 'package:truckpro/views/drivers_view_admin.dart';


class CompaniesView extends StatefulWidget {
  final Future<List<Company>> companiesFuture;
  final String token;

  const CompaniesView({super.key, required this.companiesFuture, required this.token});

  @override
  _CompaniesViewState createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> {
  late Future<List<Company>> companiesFuture;

  @override
  void initState() {
    super.initState();
    companiesFuture = widget.companiesFuture;
  }

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
        elevation: 0, 
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
                  return Dismissible(
                    key: Key(company.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _confirmAndDeleteCompany(company.id, index, company.name);
                    },
                    child: Card(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriversViewAdmin(
                                driversFuture: AdminApiService().getDriversByCompanyId(company.id, widget.token),
                                companyName: company.name,
                                adminService: AdminApiService(),
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                      ),
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

  Future<void> _confirmAndDeleteCompany(int? companyId, int index, String companyName) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the company "$companyName?"'),
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
      _deleteCompany(companyId, index, companyName);
    }
  }

  Future<void> _deleteCompany(int? companyId, int index, String companyName) async {
  try {
    AdminApiService adminService = AdminApiService();

    var response = await adminService.deleteCompany(companyId!, widget.token);

  

    if (response.contains('Company deleted successfully')) {
      setState(() {
        companiesFuture = companiesFuture.then((companies) {
          companies.removeAt(index);
          return companies;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company "$companyName" deleted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting company: $e')),
    );
  }
}
  
}
