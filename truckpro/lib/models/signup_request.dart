class SignUpRequest {
  final String email;
  final String password;
  final String name;
  final String confirmpassword;

  SignUpRequest({required this.email, required this.password, required this.name, required this.confirmpassword});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmpassword': confirmpassword,
      'name': name,
    };
  }
}
