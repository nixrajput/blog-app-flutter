import 'package:flutter/foundation.dart';

class BlogPost with ChangeNotifier {
  String title;
  String body;
  String imageUrl;
  String slug;
  String timestamp;
  String author;
  String authorId;
  String profilePicUrl;
  int likeCount;
  List<dynamic> likes;
  bool isLiked;

  BlogPost({
    this.title,
    this.body,
    this.imageUrl,
    this.slug,
    this.timestamp,
    this.author,
    this.authorId,
    this.profilePicUrl,
    this.likeCount,
    this.likes,
    this.isLiked,
  });
}
