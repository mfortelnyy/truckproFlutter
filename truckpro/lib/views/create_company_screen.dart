import 'package:flutter/material.dart';
import '../models/company.dart';
import '../utils/admin_api_service.dart';

class CreateCompanyScreen extends StatefulWidget {
  final AdminApiService adminService;
  final String token;

  const CreateCompanyScreen({super.key, required this.adminService, required this.token});

  @override
  CreateCompanyScreenState createState() => CreateCompanyScreenState();
}

class CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        String companyName = _companyNameController.text.trim();
        Company newCompany =  Company(name: companyName);
        var res = await widget.adminService.createCompany(newCompany, widget.token);
        if (res.contains('Company created successfully!')) {
          setState(() {
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Company "$companyName" created successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        }
      } catch (e) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating company: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Company'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createCompany,
                      child: const Text('Create New Company'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
