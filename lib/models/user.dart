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
}
