import 'package:flutter/foundation.dart';

class BlogPost with ChangeNotifier {
  final int id;
  final String title;
  final String body;
  final String imageUrl;
  final String slug;
  final String timestamp;
  final String author;
  final String authorId;
  final String profilePicUrl;

  BlogPost({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.slug,
    this.timestamp,
    this.author,
    this.authorId,
    this.profilePicUrl,
  });
}
