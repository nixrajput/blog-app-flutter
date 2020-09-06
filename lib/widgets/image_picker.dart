import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final Function(File pickedImage) imagePickFunc;

  const CustomImagePicker(this.imagePickFunc);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File _imageFile;

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
        _imageFile = _croppedFile;
      });
      widget.imagePickFunc(_croppedFile);
    }
  }

  clearPostInfo() {
    setState(() {
      _imageFile = null;
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
                  FlatButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _pickImage(ImageSource.camera);
                    },
                    icon: Icon(
                      Icons.camera,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: const Text("Camera"),
                    textColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _pickImage(ImageSource.gallery);
                    },
                    icon: Icon(
                      Icons.photo,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: const Text("Gallery"),
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _imageFile != null
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: FileImage(_imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2,
                color: Colors.grey.shade300,
                child: Center(
                  child: FlatButton.icon(
                    onPressed: () {
                      _showImageBottomSheet(context);
                    },
                    icon: Icon(
                      Icons.image,
                    ),
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      "Add Image",
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
