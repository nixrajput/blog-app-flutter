import 'package:blog_api_app/providers/user_provider.dart';
import 'package:blog_api_app/screens/views/chat_view.dart';
import 'package:blog_api_app/screens/views/home_view.dart';
import 'package:blog_api_app/screens/views/notification_view.dart';
import 'package:blog_api_app/screens/views/search_view.dart';
import 'package:blog_api_app/widgets/app_bar/main_app_bar.dart';
import 'package:blog_api_app/widgets/common/custom_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  size: 24.0,
                  color: _currentIndex == 0
                      ? Colors.blueAccent
                      : Theme.of(context).accentColor,
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
                  _currentIndex == 1
                      ? Icons.search_rounded
                      : Icons.search_outlined,
                  size: 24.0,
                  color: _currentIndex == 1
                      ? Colors.blueAccent
                      : Theme.of(context).accentColor,
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
                  _currentIndex == 2 ? Icons.send_rounded : Icons.send_outlined,
                  size: 24.0,
                  color: _currentIndex == 2
                      ? Colors.blueAccent
                      : Theme.of(context).accentColor,
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
                  _currentIndex == 3
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined,
                  size: 24.0,
                  color: _currentIndex == 3
                      ? Colors.blueAccent
                      : Theme.of(context).accentColor,
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
