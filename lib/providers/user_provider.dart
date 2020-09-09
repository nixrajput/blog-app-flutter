import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webapp/helpers/http_exception.dart';
import 'package:webapp/models/user.dart';

const apiAccountUrl = 'https://nixlab-blog-api.herokuapp.com/account';
const apiBlogUrl = 'https://nixlab-blog-api.herokuapp.com';

class UserDataProvider with ChangeNotifier {
  List<User> _userData = [];
  final String token;
  final String userId;

  UserDataProvider(this.token, this.userId, this._userData);

  List<User> get userData {
    return [..._userData];
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
      '$apiAccountUrl/details/$userId/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
    );

    final responseData = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      List<User> _fetchUserData = [];
      _fetchUserData.add(
        User(
          id: responseData['id'],
          firstName: responseData['first_name'],
          lastName: responseData['last_name'],
          email: responseData['email'],
          username: responseData['username'],
          dob: responseData['dob'],
          phone: responseData['phone'],
          image: responseData['profile_picture']['image'],
        ),
      );
      _userData = _fetchUserData;
    } else {
      throw HttpException(responseData['detail']);
    }
  }

  Future<void> uploadProfilePicture(File image, String timestamp) async {
    Map<String, String> headers = {
      'Authorization': 'Token $token',
    };

    var _apiUrl = Uri.parse('$apiAccountUrl/upload_profile_picture/');

    var request = http.MultipartRequest("POST", _apiUrl);
    request.headers.addAll(headers);
    request.fields['timestamp'] = timestamp;

    var fileStream = http.ByteStream(image.openRead());
    var fileLength = await image.length();
    var multiPartFile = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: image.path,
    );
    request.files.add(multiPartFile);

    var response = await request.send();
    print(response.statusCode);
    final responseString = await http.Response.fromStream(response);
    final responseData = json.decode(utf8.decode(responseString.bodyBytes));
    print(response.statusCode);
    print(responseData);
    notifyListeners();
  }

  Future<void> updateUserData(
    String firstName,
    String lastName,
    String phone,
    String dob,
    String timestamp,
  ) async {
    final response = await http.put(
      '$apiAccountUrl/update/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(<String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'dob': dob,
        'timestamp': timestamp,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      notifyListeners();
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      print(errorData);
      throw HttpException(errorData['detail']);
    }
  }
}
