import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/widgets/post_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _token;

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<BlogProvider>(ctx, listen: false).fetchBlogPost();
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
                    "Username",
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
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("BlogAPI"),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(context, CreateBlogPost.routeName);
                }),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  _showSettingBottomSheet(context);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: Consumer<BlogProvider>(
                    builder: (ctx, blogPostData, _) =>
                        blogPostData.blogPosts.length > 0
                            ? ListView.builder(
                                itemCount: blogPostData.blogPosts.length,
                                itemBuilder: (ctx, i) => BlogPostItem(
                                  title: blogPostData.blogPosts[i].title,
                                  body: blogPostData.blogPosts[i].body,
                                  image: blogPostData.blogPosts[i].image,
                                  slug: blogPostData.blogPosts[i].slug,
                                  author: blogPostData.blogPosts[i].author,
                                  authorId: blogPostData.blogPosts[i].authorId,
                                  timestamp: DateFormat.yMMMd().format(
                                      DateTime.parse(
                                          blogPostData.blogPosts[i].timestamp)),
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
            }));
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
