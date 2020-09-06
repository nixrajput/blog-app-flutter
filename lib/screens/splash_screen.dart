import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/screens/login_screen.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash-screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _token;
  var _isLoading = false;

  checkToken() async {
    setState(() {
      _isLoading = true;
    });
    final _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString("token");

    if (_token != null) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BlogAPI",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 40.0,
              ),
            ),
            Text(
              "A Blogging World",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            if (_isLoading)
              CircularProgressIndicator(
                strokeWidth: 2.0,
              )
          ],
        ),
      ),
    );
  }
}
