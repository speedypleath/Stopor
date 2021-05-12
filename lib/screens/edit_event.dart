import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/fade_background.dart';
import 'package:stopor/widgets/form_row.dart';

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
  _EditEvent(this.type, this.event);

  PickedFile _image;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Add Event"),
      ),
      body: ListView(
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
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditField(
                        field: "Name",
                        value: event.name == null ? "" : event.name))).then(
                (value) => setState(() => {
                      setOverlayWhite(),
                      event.name = value != "" ? value : null
                    })),
            child: FormRow(
              icon: Icons.edit,
              title: "Event name",
              text:
                  event.name == null ? "Enter event name here..." : event.name,
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditField(
                        field: "Description",
                        value: event.description == null
                            ? ""
                            : event.description))).then((value) => setState(
                () => {
                      setOverlayWhite(),
                      event.description = value != "" ? value : null
                    })),
            child: FormRow(
              icon: Icons.description,
              title: "Description",
              text: event.description == null
                  ? "Enter description here..."
                  : event.description,
            ),
          ),
          InkWell(
            onTap: () => {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 20))
                  .then((value) => {
                        event.date = value,
                        showTimePicker(
                                context: context, initialTime: TimeOfDay.now())
                            .then((value) => setState(() => event.date =
                                DateTime(event.date.year, event.date.month,
                                    event.date.day, value.hour, value.minute)))
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
          type == "in person"
              ? InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: APIKeys.mapsKey,
                        onPlacePicked: (result) {
                          setState(() {
                            event.location = result.formattedAddress;
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
                )
              : InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditField(
                              field: "Invite link",
                              value: event.inviteLink == null
                                  ? ""
                                  : event.inviteLink))).then((value) =>
                      setState(() => {
                            setOverlayWhite(),
                            event.inviteLink = value != "" ? value : null
                          })),
                  child: FormRow(
                    icon: Icons.public,
                    title: "Online",
                    text: event.inviteLink == null
                        ? "Enter invite link here..."
                        : event.inviteLink,
                  ),
                ),
          ElevatedButton(
            onPressed: () {
              DatabaseService databaseService = DatabaseService();
              databaseService.uploadPic(_image.path).then((value) => {
                    event.eventImage = value,
                    databaseService.uploadEvent(event)
                  });
            },
            child: Text("Submit"),
          )
        ],
      ),
    );
  }
}
