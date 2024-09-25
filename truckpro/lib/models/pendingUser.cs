using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace truckpro.lib.models
{
    public class PendingUser
    {
        final int id;
        final String email;
        final String? invitationToken;
        final bool isRegistered;

        PendingUser({
            required this.id,
            required this.email,
            required this.invitationToken,
            required this.isRegistered,
        });

        factory PendingUser.fromJson(Map<String, dynamic> json) {
            return PendingUser(
            id: json['id'],
            email: json['email'],
            invitationToken: json['invitation_token'],
            isRegistered: json['is_registered'],
            );
        }

        Map<String, dynamic> toJson() {
            return {
            'id': id,
            'email': email,
            'invitation_token': invitationToken,
            'is_registered': isRegistered,
            };
        }          
    }
}