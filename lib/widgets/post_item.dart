import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';

class BlogPostItem extends StatelessWidget {
  final String title;
  final String body;
  final String image;
  final String slug;
  final String author;
  final String authorId;
  final String timestamp;

  BlogPostItem({
    this.title,
    this.body,
    this.image,
    this.slug,
    this.author,
    this.authorId,
    this.timestamp,
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
                    onTap: () async {
                      try {
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
          ListTile(
            leading: CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.grey,
            ),
            title: Text(author),
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
                Icons.expand_more_sharp,
              ),
            ),
          ),
          Image.network(
            image,
            width: screenSize.width,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              title,
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
            child: Text(body),
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
