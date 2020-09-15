import 'package:blog_api_app/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "settings-screen";

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar("Settings", Center(), Icons.arrow_back, () {
              Navigator.pop(context);
            })
          ],
        ),
      ),
    );
  }
}
