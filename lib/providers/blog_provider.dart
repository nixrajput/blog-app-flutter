import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webapp/helpers/http_exception.dart';
import 'package:webapp/models/blog_post.dart';

const apiAccountUrl = 'https://nixlab-blog-api.herokuapp.com/account';
const apiBlogUrl = 'https://nixlab-blog-api.herokuapp.com';

class BlogProvider with ChangeNotifier {
  List<BlogPost> _blogPosts = [];
  final String token;
  final String userId;

  BlogProvider(this.token, this.userId, this._blogPosts);

  List<BlogPost> get blogPosts {
    return [..._blogPosts];
  }

  Future<void> fetchBlogPost() async {
    final response = await http.get(
      '$apiBlogUrl/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final latestData = json.decode(utf8.decode(response.bodyBytes));
      List<BlogPost> _fetchedBlogPost = [];
      for (int i = 0; i < latestData.length; i++) {
        var post = latestData[i];
        final authorData = await http.get(
          '$apiAccountUrl/details/${post['author_id']}',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
        );
        final authorDetails = json.decode(utf8.decode(authorData.bodyBytes));
        _fetchedBlogPost.add(
          BlogPost(
            id: post['id'],
            title: post['title'],
            body: post['body'],
            imageUrl: post['image'],
            slug: post['slug'],
            timestamp: post['timestamp'],
            author: authorDetails['username'],
            authorId: authorDetails['id'],
            profilePicUrl: authorDetails['profile_picture']['image'],
          ),
        );
      }
      _blogPosts = _fetchedBlogPost.reversed.toList();
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      print(errorData);
      throw HttpException(errorData['error_message']);
    }
  }

  Future<void> deletePost(String slug) async {
    final existingProductIndex =
        _blogPosts.indexWhere((post) => post.slug == slug);
    var existingProduct = _blogPosts[existingProductIndex];

    final response = await http.delete(
      '$apiBlogUrl/$slug/delete/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
    );
    _blogPosts.removeAt(existingProductIndex);
    notifyListeners();
    if (response.statusCode >= 400) {
      print(response.statusCode);
      _blogPosts.insert(existingProductIndex, existingProduct);
      notifyListeners();
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      print(errorData);
      throw HttpException('DELETION_FAILED');
    }
    existingProduct = null;
  }

  Future<void> createPost(
      File image, String title, String body, String timestamp) async {
    Map<String, String> headers = {
      'Authorization': 'Token $token',
    };

    var apiUrl = Uri.parse('$apiBlogUrl/create/');

    var request = http.MultipartRequest("POST", apiUrl);
    request.headers.addAll(headers);
    request.fields['title'] = title;
    request.fields['body'] = body;
    request.fields['timestamp'] = timestamp;

    var fileStream = http.ByteStream(image.openRead());
    var fileLength = await image.length();
    var multiPartFile = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: image.path,
    );
    request.files.add(multiPartFile);

    var response = await request.send();
    print(response.statusCode);
    final responseString = await http.Response.fromStream(response);
    final responseData = json.decode(utf8.decode(responseString.bodyBytes));

    if (response.statusCode == 201) {
      print(responseData);
      final newBlogPost = BlogPost(
        id: responseData['id'],
        title: responseData['title'],
        body: responseData['body'],
        imageUrl: responseData['image'],
        timestamp: responseData['timestamp'],
        slug: responseData['slug'],
        author: responseData['author'],
        authorId: responseData['author_id'],
      );
      _blogPosts.insert(0, newBlogPost);
      notifyListeners();
    } else {
      print(responseData);
    }
  }
}
