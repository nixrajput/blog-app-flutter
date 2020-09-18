import 'package:blog_api_app/providers/auth_provider.dart';
import 'package:blog_api_app/providers/user_provider.dart';
import 'package:blog_api_app/screens/add_post_screen.dart';
import 'package:blog_api_app/screens/login_screen.dart';
import 'package:blog_api_app/screens/profile_screen.dart';
import 'package:blog_api_app/screens/settings_screen.dart';
import 'package:blog_api_app/widgets/buttons/bottom_sheet_button.dart';
import 'package:blog_api_app/widgets/common/custom_divider.dart';
import 'package:blog_api_app/widgets/image_helper/rounded_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatelessWidget {
  void _showSettingBottomSheet(BuildContext context, String username) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 10.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Text(
              username,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: "Alata",
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          CustomDivider(),
          BottomSheetButton(
            icon: AntDesign.profile,
            title: "Profile",
            onTap: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
          BottomSheetButton(
            icon: AntDesign.setting,
            title: "Settings",
            onTap: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
          BottomSheetButton(
            icon: AntDesign.close,
            title: "Logout",
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout().then(
                (_) {
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BlogAPI",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Kaushan Script",
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        AntDesign.plus,
                        size: 32.0,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, CreateBlogPost.routeName);
                      },
                    ),
                    SizedBox(width: 16.0),
                    Consumer<UserDataProvider>(
                      builder: (_, userData, __) => GestureDetector(
                        onTap: () {
                          _showSettingBottomSheet(
                            context,
                            userData.currentUserData.first.username,
                          );
                        },
                        child: userData.currentUserData.isEmpty
                            ? CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: CircularProgressIndicator(),
                              )
                            : RoundedNetworkImage(
                                imageSize: 40.0,
                                imageUrl: userData.currentUserData.first.image,
                                strokeWidth: 0.0,
                                strokeColor: Theme.of(context).accentColor,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomDivider(),
        ],
      ),
    );
  }
}
