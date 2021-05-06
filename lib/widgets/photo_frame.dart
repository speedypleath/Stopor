import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stopor/widgets/fade_background.dart';

class PhotoFrame extends StatefulWidget {
  final String photo;
  PhotoFrame(this.photo);
  @override
  State<StatefulWidget> createState() {
    return _PhotoFrame();
  }
}

class _PhotoFrame extends State<PhotoFrame> {
  PickedFile _image;
  ImagePicker _picker = new ImagePicker();

  _imgFromCamera() async {
    PickedFile image = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 200.0,
      maxHeight: 300.0,
    );
    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    PickedFile image = await _picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 640.0,
        maxHeight: 360.0);
    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    print("da");
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _showPicker(context),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.3,
        child: FadedBackground(
          onTap: _showPicker,
          child: Expanded(
            child: _image == null
                ? Image.asset("assets/images/thunderdome.jpg", fit: BoxFit.fill)
                : Image.file(File(_image.path), fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
