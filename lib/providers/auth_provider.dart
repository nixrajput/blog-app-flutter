import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/helpers/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _loginUser(String username, String password) async {
    final http.Response response = await http.post(
      'https://nixlab-blog-api.herokuapp.com/account/login/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);

      _token = responseData['token'];
      _userId = responseData['id'];
      notifyListeners();

      final _prefs = await SharedPreferences.getInstance();
      final _userData = json.encode({
        "token": _token,
        "id": _userId,
      });
      _prefs.setString('userData', _userData);
    } else {
      final errorData = jsonDecode(response.body);
      print(errorData);
      throw HttpException(errorData['error_message']);
    }
  }

  Future<void> _createUser(
    String email,
    String username,
    String password,
    String password2,
  ) async {
    final response = await http.post(
      'https://nixlab-blog-api.herokuapp.com/account/register/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'username': username,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print(responseData);
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      print(errorData);
      throw HttpException(errorData['error_message']);
    }
  }

  Future<void> login(String username, String password) async {
    return _loginUser(username, password);
  }

  Future<void> register(
      String email, String username, String password, String password2) async {
    return _createUser(email, username, password, password2);
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedUserData['token'];
    _userId = extractedUserData['id'];
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }
}
