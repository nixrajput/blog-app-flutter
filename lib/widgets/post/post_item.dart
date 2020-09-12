import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/screens/user_profile_screen.dart';
import 'package:webapp/widgets/bottom_sheet/bottom_sheet_button.dart';
import 'package:webapp/widgets/image_helper/rounded_network_image.dart';

class BlogPostItem extends StatelessWidget {
  final String title;
  final String body;
  final String imageUrl;
  final String slug;
  final String timestamp;
  final String author;
  final String authorId;
  final String profilePicUrl;
  final String likeCount;
  final bool isLiked;
  final String commentCount;
  final String repeatCount;

  BlogPostItem({
    this.title,
    this.body,
    this.imageUrl,
    this.slug,
    this.timestamp,
    this.author,
    this.authorId,
    this.profilePicUrl,
    this.likeCount = "0",
    this.isLiked = false,
    this.commentCount = "0",
    this.repeatCount = "0",
  });

  void _showPostBottomSheet(BuildContext context, String slug, String authorId,
      String author, String currentUserId) {
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
                if (authorId != currentUserId)
                  BottomSheetButton(
                    icon: Icons.person_add_rounded,
                    title: "Follow @$author",
                    onTap: () {
                      Navigator.pushNamed(context, UserProfileScreen.routeName,
                          arguments: {'userId': authorId});
                    },
                  ),
                if (authorId == currentUserId)
                  BottomSheetButton(
                    title: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),
                if (authorId == currentUserId)
                  BottomSheetButton(
                    title: "Delete",
                    icon: Icons.delete_forever,
                    onTap: () {
                      _showDeleteDialog(context, slug);
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

  void _showDeleteDialog(BuildContext context, String slug) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete"),
        content: Text("Are you sure to delete this post."),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text("NO"),
          ),
          FlatButton(
            onPressed: () async {
              try {
                Navigator.pop(ctx);
                await Provider.of<BlogProvider>(context, listen: false)
                    .deletePost(slug)
                    .then((_) {
                  final SnackBar _snackBar = SnackBar(
                    content: Text("Post deleted"),
                  );
                  Scaffold.of(context).showSnackBar(_snackBar);
                });
              } catch (error) {
                final SnackBar _snackBar = SnackBar(
                  content: Text("An error occurred."),
                );
                Scaffold.of(context).showSnackBar(_snackBar);
              }
            },
            child: Text("YES"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
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
          postHead(context, auth),
          postBody(context, screenSize),
          Divider(),
          postBottom(context),
        ],
      ),
    );
  }

  Widget postHead(BuildContext context, auth) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, UserProfileScreen.routeName,
              arguments: {'userId': authorId});
        },
        child: RoundedNetworkImage(
          imageSize: 48.0,
          imageUrl: profilePicUrl,
          strokeWidth: 0.0,
          strokeColor: Theme.of(context).accentColor,
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, UserProfileScreen.routeName,
              arguments: {'userId': authorId});
        },
        child: Text(
          author,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: Text(
        timestamp,
      ),
      trailing: IconButton(
        onPressed: () {
          _showPostBottomSheet(
            context,
            slug,
            authorId,
            author,
            auth.userId,
          );
        },
        icon: Icon(
          Icons.expand_more,
        ),
      ),
    );
  }

  Widget postBody(BuildContext context, screenSize) {
    return Column(
      children: [
        CachedNetworkImage(
          progressIndicatorBuilder: (ctx, url, downloadProgress) => Center(
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
          imageUrl: imageUrl,
          width: screenSize.width,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10.0,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        if (body != '')
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Text(body),
          )
      ],
    );
  }

  Widget postBottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 20.0,
        left: 10.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlatButton.icon(
            onPressed: () {
              Provider.of<BlogProvider>(context, listen: false)
                  .postLikeToggle(slug);
            },
            icon: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: isLiked ? Theme.of(context).accentColor : Colors.grey,
            ),
            label: Text(
              likeCount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.messenger_rounded,
              color: Colors.grey,
            ),
            label: Text(
              commentCount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.repeat_rounded, color: Colors.grey),
            label: Text(
              repeatCount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}