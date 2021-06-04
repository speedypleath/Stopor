import 'package:flutter/material.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:stopor/models/user.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:provider/provider.dart';

class ViewEvent extends StatefulWidget {
  final Event event;
  ViewEvent({this.event});
  @override
  _ViewEventState createState() => _ViewEventState(event: event);
}

class _ViewEventState extends State<ViewEvent> {
  _ViewEventState({this.event}) {
    setOverlayWhite();
  }
  String _name;
  Image _image;
  final Event event;
  final DatabaseService _databaseService = new DatabaseService();

  Widget _buildInfoRow(icon, title, text) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(20, 20, 10, 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).accentColor),
                child: Icon(
                  icon,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 17, 0, 17),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, text == "" ? 12 : 0, 0, 0),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      text != ""
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.0,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerRow() {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipOval(
                  child: Container(
                    height: _width * 0.2,
                    width: _width * 0.2,
                    child: _image,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: _width * 0.2,
                  width: _width * 0.2,
                  margin: EdgeInsets.fromLTRB(0, _height * 0.015, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 10, 15),
          child: OutlinedButton(
            onPressed: () {},
            child: Text("Follow"),
            style: OutlinedButton.styleFrom(
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.3,
                MediaQuery.of(context).size.height * 0.05,
              ),
              primary: Colors.green,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                width: 1.0,
                color: Colors.green,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _databaseService.getUser(event.organiser), // async work
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading....');
              default:
                if (!snapshot.hasData)
                  return Container();
                else {
                  String photoURL = snapshot.data.pfp;
                  _image = photoURL != null
                      ? Image.network(photoURL,
                          width: 150.0, height: 150.0, fit: BoxFit.contain)
                      : Image.asset("assets/images/default_pfp.jpg",
                          width: 150.0, height: 150.0, fit: BoxFit.contain);
                  _name = snapshot.data.name;
                  return NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          toolbarHeight: 28,
                          floating: true,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ];
                    },
                    body: ListView(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: event.eventImage != null
                              ? Image.network(
                                  event.eventImage,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  "assets/images/thunderdome.jpg",
                                  fit: BoxFit.fill,
                                ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: AutoSizeText(
                              event.name,
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                          ),
                        ),
                        _buildOrganizerRow(),
                        _buildInfoRow(Icons.calendar_today, "Date",
                            event.date.toString()),
                        _buildInfoRow(Icons.public, "Online Event", ""),
                        _buildInfoRow(Icons.face, "Facebook",
                            "https://www.facebook.com/events/${event.facebookId}"),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            "About",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: AutoSizeText(
                              event.description,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}
