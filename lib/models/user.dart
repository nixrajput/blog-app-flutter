import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String id;
  String firstName;
  String lastName;
  String email;
  String username;
  String phone;
  String image;
  String dob;
  String accountType;
  String about;
  List<dynamic> followers;
  List<dynamic> following;
  bool isFollowing;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.phone,
    this.image,
    this.dob,
    this.accountType,
    this.about,
    this.followers,
    this.following,
    this.isFollowing,
  });
}
