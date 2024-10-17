import 'company.dart';

class UserDto {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  int role;
  int companyId;
  Company? company;
  bool emailVerified;
  String? emailVerificationToken;

  UserDto(
  {
    required this.id,    
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.emailVerified,
    required this.emailVerificationToken,    
    this.company,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
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
