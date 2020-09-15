import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/profile_screen.dart';
import 'package:webapp/screens/settings_screen.dart';
import 'package:webapp/screens/views/chat_view.dart';
import 'package:webapp/screens/views/home_view.dart';
import 'package:webapp/screens/views/notification_view.dart';
import 'package:webapp/screens/views/search_view.dart';
import 'package:webapp/widgets/bottom_sheet/bottom_sheet_button.dart';
import 'package:webapp/widgets/image_helper/rounded_network_image.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);

  pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage((index),
          duration: Duration(milliseconds: 100), curve: Curves.easeInCirc);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: Provider.of<UserDataProvider>(context, listen: false)
                  .fetchCurrentUserData(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  print('${snapshot.error}');
                  return Icon(Icons.error);
                }
                return Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
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
                                  fontWeight: FontWeight.w800),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 32.0,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, CreateBlogPost.routeName);
                                  },
                                ),
                                SizedBox(width: 20.0),
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
                                            imageUrl: userData
                                                .currentUserData.first.image,
                                            strokeWidth: 0.0,
                                            strokeColor:
                                                Theme.of(context).accentColor,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).accentColor,
                        height: 0.0,
                      )
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  pageChanged(index);
                },
                children: <Widget>[
                  HomeView(),
                  SearchView(),
                  ChatView(),
                  NotificationView(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(
              color: Theme.of(context).accentColor,
              height: 0.0,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                height: 56.0,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                        bottomTapped(0);
                      },
                      minWidth: 40.0,
                      child: Container(
                        child: IconTheme(
                          data: IconThemeData(
                            size: 24.0,
                            color: _currentIndex == 0
                                ? Colors.blueAccent
                                : Theme.of(context).accentColor,
                          ),
                          child: Icon(
                            _currentIndex == 0
                                ? Icons.home_rounded
                                : Icons.home_outlined,
                          ),
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                        bottomTapped(1);
                      },
                      minWidth: 40.0,
                      child: Container(
                        child: IconTheme(
                          data: IconThemeData(
                            size: 24.0,
                            color: _currentIndex == 1
                                ? Colors.blueAccent
                                : Theme.of(context).accentColor,
                          ),
                          child: Icon(
                            _currentIndex == 1
                                ? Icons.search_rounded
                                : Icons.search_outlined,
                          ),
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                        bottomTapped(2);
                      },
                      minWidth: 40.0,
                      child: Container(
                        child: IconTheme(
                          data: IconThemeData(
                            size: 24.0,
                            color: _currentIndex == 2
                                ? Colors.blueAccent
                                : Theme.of(context).accentColor,
                          ),
                          child: Icon(
                            _currentIndex == 2
                                ? Icons.send_rounded
                                : Icons.send_outlined,
                          ),
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 3;
                        });
                        bottomTapped(3);
                      },
                      minWidth: 40.0,
                      child: Container(
                        child: IconTheme(
                          data: IconThemeData(
                            size: 24.0,
                            color: _currentIndex == 3
                                ? Colors.blueAccent
                                : Theme.of(context).accentColor,
                          ),
                          child: Icon(
                            _currentIndex == 3
                                ? Icons.notifications_rounded
                                : Icons.notifications_outlined,
                          ),
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

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
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context).accentColor,
                ),
                BottomSheetButton(
                  icon: Icons.person_outline,
                  title: "Profile",
                  onTap: () {
                    Navigator.pushNamed(context, ProfileScreen.routeName);
                  },
                ),
                BottomSheetButton(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  },
                ),
                BottomSheetButton(
                  icon: Icons.clear,
                  title: "Logout",
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .logout()
                        .then((_) {
                      Navigator.pushReplacementNamed(
                          context, LoginScreen.routeName);
                    });
                  },
                ),
              ],
            ));
  }
}
