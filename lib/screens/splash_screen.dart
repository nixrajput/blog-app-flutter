import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash-screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _isLoading = false;

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
