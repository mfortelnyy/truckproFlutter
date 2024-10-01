class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final int role;
  final int companyId;
  final bool emailVerified;
  final String? emailVerificationToken;

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
      emailVerificationToken: json['emailVerificationToken']
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
      'emailVerificationToken': emailVerificationToken
    };
  }
}
