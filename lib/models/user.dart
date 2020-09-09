import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phone;
  final String image;
  final String dob;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.phone,
    this.image,
    this.dob,
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      username: data['username'],
      phone: data['phone'],
      image: data['profile_picture']['image'],
      dob: data['dob'],
    );
  }
}
