class Company {
  final int? id;
  final String name;
  //final String email;
  //final String address;
  //final String phoneNumber;

  Company({
    this.id,
    required this.name,
    //required this.email,
    //required this.address,
    //required this.phoneNumber,
  });

  //create a Company from JSON data
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      //email: json['email'],
      //address: json['address'],
      //phoneNumber: json['phone_number'],
    );
  }

  //company object => JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      //'email': email,
      //'address': address,
      //'phone_number': phoneNumber,
    };
  }
}
