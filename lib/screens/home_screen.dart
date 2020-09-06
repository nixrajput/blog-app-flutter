import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/models/blog_post.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BlogPost> _futureBlogPost;
  var _isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _token;
  String _username;
  String _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchBlogPost();
  }

  getToken() async {
    final _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString("token");
    _username = _prefs.getString("username");
    _currentUserId = _prefs.getString("id");
    if (_token == null) {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
    return _token;
  }

  Future<void> _fetchBlogPost() async {
    setState(() {
      _isLoading = true;
    });
    await getToken();
    final response = await http.get(
      'https://nixlab-blog-api.herokuapp.com/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $_token',
      },
    );
    if (response.statusCode == 200) {
      final latestData = jsonDecode(response.body);
      print(latestData);
      List<BlogPost> _fetchedBlogPost = [];
      var postList = latestData['results'];
      for (int i = 0; i < postList.length; i++) {
        var post = postList[i];
        _fetchedBlogPost.add(
          BlogPost(
            id: post['id'],
            title: post['title'],
            body: post['body'],
            image: post['image'],
            slug: post['slug'],
            author: post['author'],
            authorId: post['author_id'],
            timestamp: post['timestamp'],
          ),
        );
      }

      _futureBlogPost = _fetchedBlogPost.reversed.toList();

      setState(() {
        _isLoading = false;
      });
    } else {
      final errorData = jsonDecode(response.body);
      print(errorData);
      setState(() {
        _isLoading = false;
      });
      final _snackBar = SnackBar(content: Text(errorData['detail']));
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return errorData;
    }
  }

  Future<void> _deletePost(String slug) async {
    final response = await http.delete(
      'https://nixlab-blog-api.herokuapp.com/$slug/delete/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $_token',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      final _snackBar = SnackBar(
        content: Text(responseData['response']),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
    } else {
      final errorData = jsonDecode(response.body);
      print(errorData);
      setState(() {
        _isLoading = false;
      });
      final _snackBar = SnackBar(
        content: Text(errorData['response']),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return errorData;
    }
  }

  void _logoutUser() async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.remove("id");
    _prefs.remove("token");
    _prefs.remove("username");
    Navigator.pushReplacementNamed(context, SplashScreen.routeName);
  }

  void _showPostBottomSheet(
      BuildContext context, String slug, String authorId, String author) {
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
                if (authorId != _currentUserId)
                  BottomSheetButton(
                    icon: Icons.person_add_rounded,
                    title: "Follow $author",
                  ),
                if (authorId == _currentUserId)
                  BottomSheetButton(
                    title: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),
                if (authorId == _currentUserId)
                  BottomSheetButton(
                    title: "Delete",
                    icon: Icons.delete_forever,
                    onTap: () {
                      _deletePost(slug);
                    },
                  ),
                BottomSheetButton(
                  title: "Share",
                  icon: Icons.share,
                  onTap: () {},
                ),
                BottomSheetButton(
                  title: "Report",
                  icon: Icons.flag,
                  onTap: () {},
                ),
              ],
            ));
  }

  void _showSettingBottomSheet(BuildContext context) {
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
                    _username,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(),
                BottomSheetTextButton(
                  title: "Profile",
                  onTap: () {},
                ),
                BottomSheetTextButton(
                  title: "Settings",
                  onTap: () {},
                ),
                BottomSheetTextButton(
                  title: "Logout",
                  onTap: _logoutUser,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("BlogAPI"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, CreateBlogPost.routeName,
                    arguments: {'token': _token});
              }),
          IconButton(
            icon: Icon(Icons.person_rounded),
            onPressed: () {
              _showSettingBottomSheet(context);
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchBlogPost,
              child: ListView.builder(
                itemCount: _futureBlogPost.length,
                itemBuilder: (ctx, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 24.0,
                            backgroundColor: Colors.grey,
                          ),
                          title: Text(_futureBlogPost[i].author),
                          subtitle: Text(
                            _futureBlogPost[i].timestamp,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _showPostBottomSheet(
                                context,
                                _futureBlogPost[i].slug,
                                _futureBlogPost[i].authorId,
                                _futureBlogPost[i].author,
                              );
                            },
                            icon: Icon(
                              Icons.expand_more_sharp,
                            ),
                          ),
                        ),
                        Image.network(
                          _futureBlogPost[i].image,
                          width: screenSize.width,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _futureBlogPost[i].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: Text(_futureBlogPost[i].body),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.favorite_outline_rounded,
                                color: Colors.grey,
                              ),
                              Icon(
                                Icons.messenger_rounded,
                                color: Colors.grey,
                              ),
                              Icon(
                                Icons.repeat_rounded,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class BottomSheetButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const BottomSheetButton({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
            ),
            SizedBox(width: 20.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: "Alata",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSheetTextButton extends StatelessWidget {
  final String title;
  final Function onTap;

  const BottomSheetTextButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: "Alata",
          ),
        ),
      ),
    );
  }
}
