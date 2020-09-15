import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/widgets/loaders/custom_loading_screen.dart';
import 'package:webapp/widgets/post/post_item.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> _refreshProducts(BuildContext ctx) async {
    try {
      await Provider.of<BlogProvider>(ctx, listen: false).fetchBlogPost();
    } on SocketException {
      _showErrorDialog(ctx);
      throw HttpException('No Internet Connection');
    }
  }

  void _showErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Network Error"),
        content: Text("No internet connection available."),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text("OK"),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _refreshProducts(context),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoadingScreen();
        }
        return RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<BlogProvider>(
            builder: (_, blogPostData, __) =>
                blogPostData.allBlogPosts.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: blogPostData.allBlogPosts.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            BlogPostItem(
                              title: blogPostData.allBlogPosts[i].title,
                              body: blogPostData.allBlogPosts[i].body,
                              imageUrl: blogPostData.allBlogPosts[i].imageUrl,
                              slug: blogPostData.allBlogPosts[i].slug,
                              author: blogPostData.allBlogPosts[i].author,
                              authorId: blogPostData.allBlogPosts[i].authorId,
                              profilePicUrl:
                                  blogPostData.allBlogPosts[i].profilePicUrl,
                              likeCount: blogPostData
                                  .allBlogPosts[i].likes.length
                                  .toString(),
                              isLiked: blogPostData.allBlogPosts[i].isLiked,
                              timestamp: TimeAgo.getTimeAgo(
                                DateTime.parse(
                                  blogPostData.allBlogPosts[i].timestamp,
                                ),
                              ),
                            ),
                          ],
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
      },
    );
  }
}
