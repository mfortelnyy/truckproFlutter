using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace truckpro.lib.models
{
    public class Company
    {
        final int id;
        final String name;
        final String email;
        final String address;
        final String phoneNumber;

        Company({
            required this.id,
            required this.name,
            required this.email,
            required this.address,
            required this.phoneNumber,
        });

        //factory method to create a Company from JSON data
        factory Company.fromJson(Map<String, dynamic> json) {
            return Company(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            address: json['address'],
            phoneNumber: json['phone_number'],
            );
        }

        //converts a Company object to JSON
        Map<String, dynamic> toJson() {
            return {
            'id': id,
            'name': name,
            'email': email,
            'address': address,
            'phone_number': phoneNumber,
            };
        }
    }
}