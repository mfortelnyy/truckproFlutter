class User {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      emailVerified: json['emailVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
    };
  }
}
