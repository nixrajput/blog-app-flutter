import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/profile_screen.dart';
import 'package:webapp/widgets/bottom_sheet_button.dart';
import 'package:webapp/widgets/post_item.dart';
import 'package:webapp/widgets/rounded_network_image.dart';

const apiAccountUrl = 'https://nixlab-blog-api.herokuapp.com/account/details';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<BlogProvider>(ctx, listen: false).fetchBlogPost();
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
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              FutureBuilder(
                future: Provider.of<UserDataProvider>(context, listen: false)
                    .fetchUserData(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) {
                    print('${snapshot.error}');
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
                    child: Consumer<UserDataProvider>(
                      builder: (ctx, userData, _) => Row(
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
                                    userData.userData[0].username,
                                  );
                                },
                                child: RoundedNetworkImage(
                                  imageSize: 40.0,
                                  imageUrl: userData.userData.isNotEmpty
                                      ? userData.userData[0].image
                                      : '',
                                  strokeWidth: 2.0,
                                  strokeColor: Theme.of(context).accentColor,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
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
