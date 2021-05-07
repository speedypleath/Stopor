import 'package:flutter/material.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/form_row.dart';
import 'package:stopor/widgets/photo_frame.dart';

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

  @override
  void initState() {
    if (event == null) event = new Event();
    setOverlayWhite;
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
          PhotoFrame("aaa"),
          InkWell(
            onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditField(field: "Name")))
                .then((value) => setOverlayWhite()),
            child: FormRow(
              icon: Icons.edit,
              title: "Event name",
              text: "Enter event name here...",
            ),
          ),
          FormRow(
            icon: Icons.description,
            title: "Description",
            text: "Enter description here...",
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
              ? FormRow(
                  icon: Icons.location_pin,
                  title: "Location",
                  text: "Select location...",
                )
              : FormRow(
                  icon: Icons.public,
                  title: "Online",
                  text: "Enter invite link here...",
                ),
        ],
      ),
    );
  }
}
