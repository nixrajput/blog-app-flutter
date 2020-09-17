import 'package:blog_api_app/providers/blog_provider.dart';
import 'package:blog_api_app/widgets/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

class PostListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogPostData = Provider.of<BlogProvider>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: blogPostData.allBlogPosts.length,
      itemBuilder: (_, i) => BlogPostItem(
        title: blogPostData.allBlogPosts[i].title,
        body: blogPostData.allBlogPosts[i].body,
        imageUrl: blogPostData.allBlogPosts[i].imageUrl,
        slug: blogPostData.allBlogPosts[i].slug,
        author: blogPostData.allBlogPosts[i].author,
        authorId: blogPostData.allBlogPosts[i].authorId,
        profilePicUrl: blogPostData.allBlogPosts[i].profilePicUrl,
        likeCount: blogPostData.allBlogPosts[i].likes.length.toString(),
        isLiked: blogPostData.allBlogPosts[i].isLiked,
        timestamp: TimeAgo.getTimeAgo(
          DateTime.parse(
            blogPostData.allBlogPosts[i].timestamp,
          ),
        ),
      ),
    );
  }
}
