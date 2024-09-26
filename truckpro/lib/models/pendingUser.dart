class PendingUser {
  final int id;
  final String email;
  final String? invitationToken;
  final bool isRegistered;

  // Constructor
  PendingUser({
    required this.id,
    required this.email,
    this.invitationToken,
    required this.isRegistered,
  });

  // JSON data => PendingUser  
  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      id: json['id'],
      email: json['email'],
      invitationToken: json['invitation_token'],
      isRegistered: json['is_registered'],
    );
  }

  // PendingUser object => JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'invitation_token': invitationToken,
      'is_registered': isRegistered,
    };
  }
}
