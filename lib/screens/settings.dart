import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:stopor/api_keys.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/screens/add_event.dart';
import 'package:stopor/screens/edit_field.dart';
import 'package:stopor/util/primitive_wrapper.dart';
import 'package:image_cropper/image_cropper.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PrimitiveWrapper _nearbyEvents = PrimitiveWrapper(true);
  PrimitiveWrapper _reminder = PrimitiveWrapper(true);
  DatabaseService _databaseService = DatabaseService();
  ImagePicker _picker = new ImagePicker();
  Future<void> _connectToSpotify() async {
    var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: APIKeys.clientIdSpotify,
        redirectUrl: APIKeys.redirectURI,
        scope:
            "app-remote-control,user-modify-playback-state,playlist-read-private,user-follow-read");
    _databaseService.setUserSpotifyToken(
        context.read<AuthenticationService>().getUser().uid,
        authenticationToken);
  }

  Row _buildNotificationOptionRow(String title, PrimitiveWrapper isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
        ),
        Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: isActive.value,
              onChanged: (bool val) {
                setState(() {
                  isActive.value = !isActive.value;
                });
              },
            ))
      ],
    );
  }

  GestureDetector _buildAccountOptionRow(
      BuildContext context, String title, Function function) {
    return GestureDetector(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditField(
                  field: "Password",
                  hiddenText: true,
                ))).then((value) => {
          if (value != null)
            context
                .read<AuthenticationService>()
                .changePassword(value)
                .then((value) => showDialog(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                          content: new Text(value),
                        )))
        });
  }

  void _changeUsername() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditField(
                  field: "Username",
                  value: context
                      .read<AuthenticationService>()
                      .getUser()
                      .displayName,
                ))).then((value) => {
          if (value != null)
            context
                .read<AuthenticationService>()
                .changeUsername(value)
                .then((value) => setState(() {}))
        });
  }

  void _deleteAccount() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              content:
                  new Text("Are you sure you want to delete your account?"),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Delete'),
                    isDestructiveAction: true,
                    onPressed: () {
                      context.read<AuthenticationService>().deleteAccount();
                      Navigator.pop(context, 'Delete');
                    }),
                new CupertinoDialogAction(
                    child: const Text('Cancel'),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    }),
              ],
            ));
  }

  _imgFromCamera() async {
    PickedFile image = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    _cropImage(image);
  }

  _imgFromGallery() async {
    PickedFile image = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    _cropImage(image);
  }

  _cropImage(image) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null)
      _databaseService
          .uploadPic(croppedFile.path)
          .then((value) => {
                context.read<AuthenticationService>().changeImage(value),
              })
          .then((value) => setState(() {}));
  }

  Future<void> _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
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
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String photoURL = context.read<AuthenticationService>().getUser().photoURL;
    Image image = photoURL != null
        ? Image.network(photoURL,
            width: 150.0, height: 150.0, fit: BoxFit.contain)
        : Image.asset("assets/images/default_pfp.jpg",
            width: 150.0, height: 150.0, fit: BoxFit.contain);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: Center(
                  child: ClipOval(
                child: Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey.shade200,
                  child: image,
                ),
              )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              context.read<AuthenticationService>().getUser().displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 23,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[600]),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              "Settings",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            _buildAccountOptionRow(
                context, "Sync spotify artists", _connectToSpotify),
            _buildAccountOptionRow(context, "Sync facebook events",
                context.read<AuthenticationService>().facebookSignIn),
            _buildAccountOptionRow(context, "Add event", () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddEvent()));
            }),
            _buildAccountOptionRow(context, "Your events", () {}),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            _buildAccountOptionRow(context, "Change password", _changePassword),
            _buildAccountOptionRow(context, "Change username", _changeUsername),
            _buildAccountOptionRow(context, "Delete account", _deleteAccount),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.volume_up_outlined,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            _buildNotificationOptionRow("Nearby events", _nearbyEvents),
            _buildNotificationOptionRow("Reminders", _reminder),
            SizedBox(
              height: 50,
            ),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                },
                child: Text("SIGN OUT",
                    style: TextStyle(
                        fontSize: 16, letterSpacing: 2.2, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

