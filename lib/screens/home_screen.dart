import 'package:blog_api_app/providers/user_provider.dart';
import 'package:blog_api_app/screens/views/chat_view.dart';
import 'package:blog_api_app/screens/views/home_view.dart';
import 'package:blog_api_app/screens/views/notification_view.dart';
import 'package:blog_api_app/screens/views/search_view.dart';
import 'package:blog_api_app/widgets/app_bar/main_app_bar.dart';
import 'package:blog_api_app/widgets/common/custom_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

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
                return MainAppBar();
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
      bottomNavigationBar: BottomAppBar(child: bottomAppBar()),
    );
  }

  Column bottomAppBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDivider(),
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
              IconButton(
                icon: Icon(
                  AntDesign.home,
                  size: 24.0,
                  color: _currentIndex == 0
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  bottomTapped(0);
                },
              ),
              IconButton(
                icon: Icon(
                  AntDesign.search1,
                  size: 24.0,
                  color: _currentIndex == 1
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  bottomTapped(1);
                },
              ),
              IconButton(
                icon: Icon(
                  AntDesign.message1,
                  size: 24.0,
                  color: _currentIndex == 2
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  bottomTapped(2);
                },
              ),
              IconButton(
                icon: Icon(
                  AntDesign.notification,
                  size: 24.0,
                  color: _currentIndex == 3
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                  bottomTapped(3);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
