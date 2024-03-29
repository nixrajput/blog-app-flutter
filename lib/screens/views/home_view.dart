import 'dart:io';

import 'package:blog_api_app/helpers/http_exception.dart';
import 'package:blog_api_app/providers/blog_provider.dart';
import 'package:blog_api_app/widgets/loaders/custom_loading_screen.dart';
import 'package:blog_api_app/widgets/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

Widget homeView(BuildContext context, Future _future) {
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

  Future<void> _refreshProducts(BuildContext ctx) async {
    try {
      await Provider.of<BlogProvider>(ctx, listen: false).fetchBlogPost();
    } on SocketException {
      _showErrorDialog(ctx);
      throw HttpExceptionHelper('No Internet Connection');
    }
  }

  return FutureBuilder(
    future: _future,
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
          builder: (_, blogPostData, __) => blogPostData.allBlogPosts.length > 0
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
                        likeCount: blogPostData.allBlogPosts[i].likes.length
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
