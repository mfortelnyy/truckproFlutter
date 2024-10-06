import 'company.dart';

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;
  String phone;
  int role;
  int companyId;
  Company? company;
  bool emailVerified;
  String? emailVerificationToken;

  User(
  {
    required this.id,    
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.emailVerified,
    required this.emailVerificationToken,    
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      role: json['role'],
      companyId: json['companyId'],
      emailVerified: json['emailVerified'],
      emailVerificationToken: json['emailVerificationToken'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'companyId': companyId,
      'emailVerified': emailVerified,
      'emailVerificationToken': emailVerificationToken,
      'company': company
    };
  }
}
