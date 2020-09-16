import 'package:blog_api_app/widgets/app_bar/custom_app_bar.dart';
import 'package:blog_api_app/widgets/buttons/setting_button.dart';
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
            CustomAppBar(
              "Settings",
              Center(),
              Icons.arrow_back,
              () {
                Navigator.pop(context);
              },
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SettingButton(
                    title: "Account",
                    icon: Icons.person_rounded,
                    onTap: () {},
                  ),
                  SettingButton(
                    title: "Security",
                    icon: Icons.security_rounded,
                    onTap: () {},
                  ),
                  SettingButton(
                    title: "Media",
                    icon: Icons.folder_rounded,
                    onTap: () {},
                  ),
                  SettingButton(
                    title: "Privacy Policy",
                    icon: Icons.policy_rounded,
                    onTap: () {},
                  ),
                  SettingButton(
                    title: "About",
                    icon: Icons.info_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
