import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/helpers/http_exception.dart';
import 'package:webapp/models/user.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/profile_screen.dart';
import 'package:webapp/widgets/bottom_sheet_button.dart';
import 'package:webapp/widgets/post_item.dart';
import 'package:webapp/widgets/rounded_network_image.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';
  final String token;
  final String currentUserId;

  const HomeScreen(this.token, this.currentUserId);

  @override
  _HomeScreenState createState() => _HomeScreenState(token, currentUserId);
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<User> _userData;
  final String _token;
  final String _currentUserId;
  var _isInit = true;

  _HomeScreenState(this._token, this._currentUserId);

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<BlogProvider>(ctx, listen: false).fetchBlogPost();
  }

  Future<User> _fetchUserData() async {
    final response = await http.get(
      'https://nixlab-blog-api.herokuapp.com/account/details/$_currentUserId',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $_token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(responseData);
    } else {
      throw HttpException(responseData['detail']);
    }
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
                    ),
                  ),
                ),
                Divider(),
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
                  onTap: () {},
                ),
                BottomSheetButton(
                  icon: Icons.clear,
                  title: "Logout",
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _userData = _fetchUserData();
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              FutureBuilder<User>(
                future: _userData,
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) {
                    return Icon(Icons.error);
                  }
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0.0, 0.0),
                          blurRadius: 20.0,
                          color: Colors.grey.withOpacity(0.5),
                        )
                      ],
                    ),
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
                            GestureDetector(
                              onTap: () {
                                _showSettingBottomSheet(
                                  context,
                                  snapshot.data.username,
                                );
                              },
                              child: RoundedNetworkImage(
                                imageSize: 40.0,
                                imageUrl:
                                    snapshot.hasData ? snapshot.data.image : '',
                                strokeWidth: 2.0,
                                strokeColor: Theme.of(context).accentColor,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder(
                    future: _refreshProducts(context),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasError) {
                        print("${snapshot.error}");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: () => _refreshProducts(context),
                          child: Consumer<BlogProvider>(
                            builder: (ctx, blogPostData, _) => blogPostData
                                        .blogPosts.length >
                                    0
                                ? ListView.builder(
                                    itemCount: blogPostData.blogPosts.length,
                                    itemBuilder: (ctx, i) => BlogPostItem(
                                      title: blogPostData.blogPosts[i].title,
                                      body: blogPostData.blogPosts[i].body,
                                      imageUrl:
                                          blogPostData.blogPosts[i].imageUrl,
                                      slug: blogPostData.blogPosts[i].slug,
                                      author: blogPostData.blogPosts[i].author,
                                      authorId:
                                          blogPostData.blogPosts[i].authorId,
                                      profilePicUrl: blogPostData
                                          .blogPosts[i].profilePicUrl,
                                      timestamp: DateFormat.yMMMd().format(
                                          DateTime.parse(blogPostData
                                              .blogPosts[i].timestamp)),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48.0,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          "No post available.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}
