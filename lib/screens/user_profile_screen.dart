import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/widgets/custom_app_bar.dart';
import 'package:webapp/widgets/custom_body_text.dart';
import 'package:webapp/widgets/post_item.dart';
import 'package:webapp/widgets/post_loading_shimmer.dart';
import 'package:webapp/widgets/rounded_network_image.dart';
import 'package:webapp/widgets/shimmer_loading_effect.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = "user-profile-screen";
  final String userId;

  const UserProfileScreen(this.userId);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(userId);
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final String _userId;

  _UserProfileScreenState(this._userId);

  Widget actionButton() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<UserDataProvider>(context, listen: false)
              .fetchUserData(_userId),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              print('${snapshot.error}');
              return Text('${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerLoadingWidget(
                        width: screenSize.width,
                        height: 50.0,
                      ),
                      SizedBox(height: 10.0),
                      ShimmerLoadingWidget(
                        width: 200.0,
                        height: 200.0,
                        isCircle: true,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Consumer<UserDataProvider>(
              builder: (ctx, userData, _) => Column(
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
                        context, userData.userData.first, auth),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfileScreen(BuildContext context, user, auth) {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.0),
          _imageArea(user),
          SizedBox(height: 20.0),
          if (_userId != auth.userId)
            Consumer<UserDataProvider>(
              builder: (ctx, userData, _) => RaisedButton(
                onPressed: () async {
                  userData.userFollowToggle(_userId);
                },
                padding: EdgeInsets.symmetric(horizontal: screenSize.width / 8),
                color: user.isFollowing
                    ? Theme.of(context).accentColor
                    : Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    side: BorderSide(
                      color: Theme.of(context).accentColor,
                      width: 2.0,
                    )),
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
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                print("${snapshot.error}");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return PostLoadingShimmer();
              }
              return Consumer<BlogProvider>(
                builder: (ctx, blogPostData, _) =>
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
