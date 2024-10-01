class ManagerSignUpDto
{
    final String firstName;
    final String lastName;
    final String email;
    final String password;
    final String phone;
    final String confirmPassword;
    final int role;
    final int companyId;

    ManagerSignUpDto({
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.password,
        required this.phone,
        required this.confirmPassword,
        required this.role,
        required this.companyId,
    });

    factory ManagerSignUpDto.fromJson(Map<String, dynamic> json) {
        return ManagerSignUpDto(
        firstName: json['FirstName'],
        lastName: json['LastName'],
        email: json['Email'],
        password: json['Password'],
        phone: json['Phone'],
        confirmPassword: json['ConfirmPassword'],
        role: json['Role'],
        companyId: json['CompanyId'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
        'FirstName': firstName,
        'LastName': lastName,
        'Email': email,
        'Password': password,
        'Phone': phone,
        'ConfirmPassword': confirmPassword,
        'Role': role,
        'CompanyId': companyId,
        };
    }
    
}
