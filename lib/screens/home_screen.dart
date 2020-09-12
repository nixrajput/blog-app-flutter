import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/profile_screen.dart';
import 'package:webapp/screens/settings_screen.dart';
import 'package:webapp/widgets/bottom_sheet_button.dart';
import 'package:webapp/widgets/post_item.dart';
import 'package:webapp/widgets/post_loading_shimmer.dart';
import 'package:webapp/widgets/rounded_network_image.dart';

const apiAccountUrl = 'https://nixlab-blog-api.herokuapp.com/account/details';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              FutureBuilder(
                future: Provider.of<UserDataProvider>(context, listen: false)
                    .fetchCurrentUserData(),
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
                            Consumer<UserDataProvider>(
                              builder: (ctx, userData, _) => GestureDetector(
                                onTap: () {
                                  _showSettingBottomSheet(
                                    context,
                                    userData.currentUserData.first.username,
                                  );
                                },
                                child: RoundedNetworkImage(
                                  imageSize: 40.0,
                                  imageUrl: userData.currentUserData.isNotEmpty
                                      ? userData.currentUserData.first.image
                                      : '',
                                  strokeWidth: 2.0,
                                  strokeColor: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10.0),
              if (_isLoading) CircularProgressIndicator(),
              if (_isLoading) SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder(
                  future: _refreshProducts(context),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasError) {
                      print("${snapshot.error}");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return PostLoadingShimmer();
                    }

                    return RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<BlogProvider>(
                        builder: (ctx, blogPostData, _) => ListView.builder(
                          shrinkWrap: true,
                          itemCount: blogPostData.currentUserBlogPosts.length,
                          itemBuilder: (ctx, i) => BlogPostItem(
                            title: blogPostData.currentUserBlogPosts[i].title,
                            body: blogPostData.currentUserBlogPosts[i].body,
                            imageUrl:
                                blogPostData.currentUserBlogPosts[i].imageUrl,
                            slug: blogPostData.currentUserBlogPosts[i].slug,
                            author: blogPostData.currentUserBlogPosts[i].author,
                            authorId:
                                blogPostData.currentUserBlogPosts[i].authorId,
                            profilePicUrl: blogPostData
                                .currentUserBlogPosts[i].profilePicUrl,
                            likeCount: blogPostData
                                .currentUserBlogPosts[i].likes.length
                                .toString(),
                            isLiked:
                                blogPostData.currentUserBlogPosts[i].isLiked,
                            timestamp: TimeAgo.getTimeAgo(
                              DateTime.parse(
                                blogPostData.currentUserBlogPosts[i].timestamp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
