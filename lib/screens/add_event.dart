import 'package:flutter/material.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/fade_background.dart';
import 'package:stopor/widgets/form_row.dart';

import 'edit_event.dart';

class AddEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddEvent();
  }
}

class _AddEvent extends State<AddEvent> {
  String type = "online";
  @override
  void initState() {
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
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 180,
            child: FadedBackground(
              onTap: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditEvent(type: "online"))),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: FormRow(
                    icon: Icons.edit,
                    title: "Online event",
                    text:
                        "Add an external link for your event adfjasdfdfgggggggggggggggggggggggggggggggggggggjhASDJKLFSFGDJKLASDGjklahsdfjlash fashdfkljasdfhadfljasdhjkl",
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 130,
            child: FadedBackground(
              onTap: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditEvent(type: "in person"))),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: FormRow(
                    icon: Icons.description,
                    title: "Live event",
                    text: "Add a location for your event",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
