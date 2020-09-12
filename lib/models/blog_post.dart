import 'package:flutter/foundation.dart';

class BlogPost with ChangeNotifier {
  final String title;
  final String body;
  final String imageUrl;
  final String slug;
  final String timestamp;
  final String author;
  final String authorId;
  final String profilePicUrl;
  final int likeCount;
  final List<dynamic> likes;
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
