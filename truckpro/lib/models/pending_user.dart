
class PendingUser {
  final int id;
  final String email;
  final DateTime createdDate;
  final int companyId;
  final bool invitationSent;

  PendingUser({
    required this.id,
    required this.email,
    required this.createdDate,
    required this.companyId,
    this.invitationSent = false, 
  }) {
    
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty.');
    }
    
  }

  
  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      id: json['id'],
      email: json['email'],
      createdDate: DateTime.parse(json['createdDate']),
      companyId: json['companyId'],
      invitationSent: json['invitationSent'] ?? false, // def to false if not provided
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdDate': createdDate.toIso8601String(),
      'companyId': companyId,
      'invitationSent': invitationSent,
    };
  }
}
