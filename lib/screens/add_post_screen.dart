import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webapp/widgets/image_picker.dart';

class CreateBlogPost extends StatefulWidget {
  static const routeName = 'add-post-screen';

  @override
  _CreateBlogPostState createState() => _CreateBlogPostState();
}

class _CreateBlogPostState extends State<CreateBlogPost> {
  File _userImageFile;
  var _postTitle;
  var _postBody;
  var _isLoading = false;
  var _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  void _pickImage(File image) {
    _userImageFile = image;
  }

  Future<void> _createPost(
      File image, String title, String body, String token) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> headers = {
      'Authorization': 'Token $token',
    };

    var apiUrl = Uri.parse('https://nixlab-blog-api.herokuapp.com/create/');

    var request = http.MultipartRequest("POST", apiUrl);
    request.headers.addAll(headers);
    request.fields['title'] = title;
    request.fields['body'] = body;

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

    if (response.statusCode == 201) {
      setState(() {
        _isLoading = false;
      });

      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });

      final _snackBar = SnackBar(content: Text('Post created successfully.'));
      _scaffoldKey.currentState.showSnackBar(_snackBar);

      Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      response.stream.transform(utf8.decoder).listen((value) {
        final _snackBar = SnackBar(content: Text('$value'));
        _scaffoldKey.currentState.showSnackBar(_snackBar);
      });
    }
  }

  void _trySubmit(String token) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      final _snackBar = SnackBar(
        content: Text('Please add an image first.'),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      _createPost(_userImageFile, _postTitle, _postBody, token);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments as Map;
    final _token = args['token'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add Post"),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _trySubmit(_token);
              })
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomImagePicker(
                    _pickImage,
                  ),
                  SizedBox(height: 10.0),
                  Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: TextFormField(
                          key: ValueKey('title'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Title can't be empty!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Title", errorMaxLines: 2),
                          onSaved: (value) {
                            _postTitle = value.trim();
                          },
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: TextFormField(
                          maxLength: 1000,
                          key: ValueKey('body'),
                          decoration: InputDecoration(
                              labelText: "Write something", errorMaxLines: 2),
                          onSaved: (value) {
                            _postBody = value.trim();
                          },
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }
}
