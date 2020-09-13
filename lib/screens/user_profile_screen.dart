import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/widgets/app_bar/custom_app_bar.dart';
import 'package:webapp/widgets/image_helper/rounded_network_image.dart';
import 'package:webapp/widgets/loaders/post_loading_shimmer.dart';
import 'package:webapp/widgets/loaders/profile_loading_shimmer.dart';
import 'package:webapp/widgets/post/custom_body_text.dart';
import 'package:webapp/widgets/post/post_item.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = "user-profile-screen";

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget actionButton() {
    return IconButton(
      tooltip: "More",
      icon: Icon(
        Icons.more_vert_rounded,
        size: 32.0,
        color: Theme.of(context).accentColor,
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final _userId = args['userId'];
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<UserDataProvider>(context, listen: false)
              .fetchUserData(_userId),
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              print('${snapshot.error}');
              return Text('${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return ProfileLoadingShimmer(screenSize.width);
            }

            return Consumer<UserDataProvider>(
              builder: (_, userData, __) => Column(
                children: [
                  CustomAppBar(
                    userData.userData.first.username,
                    actionButton(),
                    Icons.arrow_back,
                    () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: buildProfileScreen(
                      context,
                      userData.userData.first,
                      auth,
                      _userId,
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

  Widget buildProfileScreen(BuildContext context, user, auth, _userId) {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.0),
          _imageArea(user),
          SizedBox(height: 20.0),
          if (_userId != auth.userId)
            Consumer<UserDataProvider>(
              builder: (_, _userData, __) => RaisedButton(
                onPressed: () async {
                  try {
                    _userData.userFollowToggle(_userId).then((value) {
                      final SnackBar _snackBar = SnackBar(
                        content: Text(value['is_following'] == true
                            ? "You are following ${_userData.userData.first.username} now."
                            : 'You unfollowed ${_userData.userData.first.username}.'),
                      );
                      _scaffoldKey.currentState.showSnackBar(_snackBar);
                    });
                  } catch (error) {
                    final SnackBar _snackBar = SnackBar(
                      content: Text("An error occurred."),
                    );
                    _scaffoldKey.currentState.showSnackBar(_snackBar);
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: screenSize.width / 8),
                color: user.isFollowing
                    ? Theme.of(context).accentColor
                    : Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Text(
                  user.isFollowing ? "Following" : "Follow",
                  style: TextStyle(
                    color: user.isFollowing
                        ? Colors.white
                        : Theme.of(context).accentColor,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          SizedBox(height: 20.0),
          CustomBodyText(
            title: "Name",
            value: "${user.firstName} ${user.lastName}",
          ),
          CustomBodyText(
            title: "Email",
            value: "${user.email}",
          ),
          Divider(
            color: Colors.grey,
          ),
          SizedBox(height: 10.0),
          FutureBuilder(
            future: Provider.of<BlogProvider>(context, listen: false)
                .fetchUserBlogPost(_userId),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                print("${snapshot.error}");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return PostLoadingShimmer();
              }
              return Consumer<BlogProvider>(
                builder: (_, blogPostData, __) =>
                    blogPostData.blogPosts.length > 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: blogPostData.blogPosts.length,
                            itemBuilder: (ctx, i) => BlogPostItem(
                              title: blogPostData.blogPosts[i].title,
                              body: blogPostData.blogPosts[i].body,
                              imageUrl: blogPostData.blogPosts[i].imageUrl,
                              slug: blogPostData.blogPosts[i].slug,
                              author: blogPostData.blogPosts[i].author,
                              authorId: blogPostData.blogPosts[i].authorId,
                              profilePicUrl: user.image,
                              likeCount: blogPostData.blogPosts[i].likes.length
                                  .toString(),
                              isLiked: blogPostData.blogPosts[i].isLiked,
                              timestamp: TimeAgo.getTimeAgo(DateTime.parse(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _imageArea(user) {
    return RoundedNetworkImage(
      imageSize: 200.0,
      imageUrl: user.image,
      strokeWidth: 4.0,
      strokeColor: Theme.of(context).accentColor,
    );
  }
}
