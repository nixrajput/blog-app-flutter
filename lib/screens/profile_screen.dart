import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:webapp/models/user.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/widgets/bottom_sheet_button.dart';
import 'package:webapp/widgets/custom_app_bar.dart';
import 'package:webapp/widgets/rounded_network_image.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "profile-screen";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _userImageFile;
  var _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final _pickedImage = await picker.getImage(
      source: source,
      imageQuality: 50,
    );

    if (_pickedImage != null) {
      File _croppedFile = await ImageCropper.cropImage(
          sourcePath: _pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Theme.of(context).canvasColor,
              toolbarTitle: "Crop Image",
              backgroundColor: Theme.of(context).canvasColor),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
            minimumAspectRatio: 1.0,
          ));

      setState(() {
        _userImageFile = _croppedFile;
      });
    }
  }

  void _trySubmit() async {
    if (_userImageFile == null) {
      final _snackBar = SnackBar(
        content: Text('Please add an image first.'),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Provider.of<UserDataProvider>(context, listen: false)
        .uploadProfilePicture(
      _userImageFile,
      DateTime.now().toString(),
    )
        .then((_) {
      Navigator.pop(context);
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        context: context,
        builder: (ctx) => Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BottomSheetButton(
                    title: "Camera",
                    icon: Icons.camera,
                    onTap: () async {
                      await _pickImage(ImageSource.camera);
                    },
                  ),
                  BottomSheetButton(
                    title: "Gallery",
                    icon: Icons.photo,
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder<User>(
          future: Provider.of<UserDataProvider>(context, listen: false)
              .fetchUserDataNew(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              print("${snapshot.error}");
              return Center(child: Text("${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Loading...",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                  SizedBox(height: 10.0),
                  CircularProgressIndicator(),
                ],
              ));
            }
            return Consumer<UserDataProvider>(
              builder: (ctx, userData, _) => Column(
                children: [
                  CustomAppBar(snapshot.data.username),
                  SizedBox(height: 20.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _userImageFile == null
                                ? GestureDetector(
                                    onTap: () {
                                      _showImageBottomSheet(context);
                                    },
                                    child: RoundedNetworkImage(
                                      imageSize: 200.0,
                                      imageUrl: snapshot.data.image,
                                      strokeWidth: 4.0,
                                      strokeColor:
                                          Theme.of(context).accentColor,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      _showImageBottomSheet(context);
                                    },
                                    child: _userImageFile != null
                                        ? _isLoading
                                            ? CircularProgressIndicator()
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    width: 200.0,
                                                    height: 200.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: FileImage(
                                                            _userImageFile),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 40.0),
                                                  RaisedButton(
                                                    onPressed: () {
                                                      _trySubmit();
                                                    },
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 16.0,
                                                    ),
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    textColor: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    child: Text("Save"),
                                                  )
                                                ],
                                              )
                                        : Container(
                                            width: 200.0,
                                            height: 200.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Add Image",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
