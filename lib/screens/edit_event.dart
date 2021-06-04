import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/fade_background.dart';
import 'package:stopor/widgets/form_row.dart';
import 'package:provider/provider.dart';
import '../api_keys.dart';
import 'edit_field.dart';

class EditEvent extends StatefulWidget {
  final String type;
  final Event event;
  EditEvent({this.type, this.event});
  @override
  State<StatefulWidget> createState() {
    if (type == null)
      return _EditEvent(event.isOnline ? "online" : "in person", event);
    return _EditEvent(type, event);
  }
}

class _EditEvent extends State<EditEvent> {
  Event event;
  final String type;
  final _formKey = GlobalKey<FormState>();
  _EditEvent(this.type, this.event);
  DatabaseService _databaseService = DatabaseService();
  PickedFile _image;
  File _croppedImage;
  ImagePicker _picker = new ImagePicker();

  getImage() {
    return _image;
  }

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
    _cropImage(image);
  }

  _cropImage(image) async {
    if (image == null) return;
    _croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
  }

  void _showPicker(context) {
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
  void initState() {
    if (event == null) event = new Event();
    setOverlayWhite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = event == null ? "Add Event" : "Edit event";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(title),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _showPicker(context),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: FadedBackground(
                    onTap: _showPicker,
                    child: _image == null
                        ? Image.asset("assets/images/thunderdome.jpg",
                            fit: BoxFit.fill)
                        : Image.file(File(_image.path), fit: BoxFit.fill),
                  ),
                )),
            Container(
              margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: FormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (FormFieldState<dynamic> field) {
                  // ignore: invalid_use_of_protected_member
                  refresh(value) => field.setValue(value);
                  return InputDecorator(
                    decoration: InputDecoration(
                      errorStyle: TextStyle(letterSpacing: 0.8),
                      contentPadding: EdgeInsets.all(0),
                      errorText: field.errorText,
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditField(
                                      field: "Name",
                                      value: event.name == null
                                          ? ""
                                          : event.name)))
                          .then((value) => setState(() => {
                                setOverlayWhite(),
                                event.name = value != "" ? value : null,
                                refresh(value != "" ? value : null),
                                field.validate()
                              })),
                      child: FormRow(
                        icon: Icons.edit,
                        title: "Event name",
                        text: event.name == null
                            ? "Enter event name here..."
                            : event.name,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: FormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (FormFieldState<dynamic> field) {
                  // ignore: invalid_use_of_protected_member
                  refresh(value) => field.setValue(value);
                  return InputDecorator(
                    decoration: InputDecoration(
                      errorStyle: TextStyle(letterSpacing: 0.8),
                      contentPadding: EdgeInsets.all(0),
                      errorText: field.errorText,
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditField(
                                      field: "Description",
                                      value: event.description == null
                                          ? ""
                                          : event.description)))
                          .then((value) => setState(() => {
                                setOverlayWhite(),
                                event.description = value != "" ? value : null,
                                refresh(value != "" ? value : null),
                                field.validate()
                              })),
                      child: FormRow(
                        icon: Icons.description,
                        title: "Description",
                        text: event.description == null
                            ? "Enter description here..."
                            : event.description,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: FormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some date';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (FormFieldState<dynamic> field) {
                  // ignore: invalid_use_of_protected_member
                  refresh(value) => field.setValue(value);
                  return InputDecorator(
                    decoration: InputDecoration(
                      errorStyle: TextStyle(letterSpacing: 0.8),
                      contentPadding: EdgeInsets.all(0),
                      errorText: field.errorText,
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 20))
                            .then((value) => {
                                  event.date = value,
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) => {
                                            setState(() => event.date =
                                                DateTime(
                                                    event.date.year,
                                                    event.date.month,
                                                    event.date.day,
                                                    value.hour,
                                                    value.minute)),
                                            refresh(value.toString()),
                                            field.validate()
                                          })
                                })
                      },
                      child: FormRow(
                        icon: Icons.calendar_today,
                        title: "Date",
                        text: event.date == null
                            ? "Select date..."
                            : event.date
                                .toString()
                                .substring(0, event.date.toString().length - 7),
                      ),
                    ),
                  );
                },
              ),
            ),
            type == "in person"
                ? Container(
                    margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
                    child: FormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      builder: (FormFieldState<dynamic> field) {
                        // ignore: invalid_use_of_protected_member
                        refresh(value) => field.setValue(value);
                        return InputDecorator(
                          decoration: InputDecoration(
                            errorStyle: TextStyle(letterSpacing: 0.8),
                            contentPadding: EdgeInsets.all(0),
                            errorText: field.errorText,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  apiKey: APIKeys.mapsKey,
                                  onPlacePicked: (result) {
                                    setState(() {
                                      event.location = result.formattedAddress;
                                      refresh(event.location != ""
                                          ? event.location
                                          : null);
                                      field.validate();
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  initialPosition: LatLng(44.4268, 26.1025),
                                  useCurrentLocation: false,
                                ),
                              ),
                            ),
                            child: FormRow(
                              icon: Icons.location_pin,
                              title: "Location",
                              text: event.location == null
                                  ? "Select location..."
                                  : event.location,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
                    child: FormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !Uri.parse(value).isAbsolute) {
                          return 'Please enter a valid url';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      builder: (FormFieldState<dynamic> field) {
                        // ignore: invalid_use_of_protected_member
                        refresh(value) => field.setValue(value);
                        return InputDecorator(
                          decoration: InputDecoration(
                            errorStyle: TextStyle(letterSpacing: 0.8),
                            contentPadding: EdgeInsets.all(0),
                            errorText: field.errorText,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditField(
                                            field: "Invite link",
                                            value: event.inviteLink == null
                                                ? ""
                                                : event.inviteLink)))
                                .then((value) => setState(() => {
                                      setOverlayWhite(),
                                      event.inviteLink =
                                          value != "" ? value : null,
                                      refresh(value != "" ? value : null),
                                      field.validate()
                                    })),
                            child: FormRow(
                              icon: Icons.public,
                              title: "Online",
                              text: event.inviteLink == null
                                  ? "Enter invite link here..."
                                  : event.inviteLink,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (_croppedImage != null)
                    _databaseService.uploadPic(_croppedImage.path).then(
                        (value) => {
                              event.eventImage = value,
                              _databaseService.uploadEvent(event)
                            });
                  else {
                    _databaseService.uploadEvent(event);
                  }
                } else {
                  print("nu");
                }
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
