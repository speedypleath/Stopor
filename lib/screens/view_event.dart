import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:stopor/models/user.dart';
import 'package:stopor/screens/edit_event.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Image _image;
  final Event event;
  final DatabaseService _databaseService = new DatabaseService();

  void _launchURL(url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

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

  Widget _buildOrganiserRow(User organiser) {
    double _width = MediaQuery.of(context).size.width;
    bool isOrganiser =
        organiser.id == context.read<AuthenticationService>().getUser().uid;
    bool isFollowing = _databaseService.isUserFollowed(organiser.id);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipOval(
                  child: Container(
                    height: _width * 0.18,
                    width: _width * 0.18,
                    child: _image,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: _width * 0.2,
                  width: _width * 0.2,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      organiser.name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        !isOrganiser
            ? Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 15),
                child: OutlinedButton(
                  onPressed: () async {
                    !isFollowing
                        ? await _databaseService.followUser(organiser.id,
                            context.read<AuthenticationService>().getUser().uid)
                        : await _databaseService.unfollowUser(
                            organiser.id,
                            context
                                .read<AuthenticationService>()
                                .getUser()
                                .uid);
                    setState(() {});
                  },
                  child: !isFollowing ? Text("Follow") : Text("Following"),
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
              )
            : Container(),
      ],
    );
  }

  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) {
    bool isFollowing = _databaseService.isEventFollowed(event.id);
    return <Widget>[
      SliverAppBar(
        toolbarHeight: 28,
        floating: true,
        actions: [
          IconButton(
            onPressed: () {
              if (isFollowing)
                _databaseService.unfollowEvent(event.id,
                    context.read<AuthenticationService>().getUser().uid);
              else
                _databaseService.followEvent(
                    event, context.read<AuthenticationService>().getUser().uid);
              setState(() {});
            },
            visualDensity: VisualDensity(horizontal: 4.0, vertical: 4.0),
            icon: Icon(
              Icons.star,
              color: isFollowing ? Colors.green : Colors.grey,
            ),
          )
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    ];
  }

  Widget _buildEventImage() {
    return SizedBox(
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
    );
  }

  Widget _buildEventName() {
    return Center(
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
    );
  }

  Widget _buildEventDescriptionCard() {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              child: Text(
                event.description,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription() {
    return ExpandableNotifier(
      child: Expandable(
        collapsed: ExpandableButton(
          theme: ExpandableThemeData(
            useInkWell: false,
          ),
          child: _buildEventDescriptionCard(),
        ),
        expanded: ExpandableButton(
          theme: ExpandableThemeData(
            useInkWell: false,
          ),
          child: Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      minFontSize: 10,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildEditEventButton(AsyncSnapshot<User> snapshot) {
    if (!snapshot.hasData) return Container();
    if (snapshot.data.id != context.read<AuthenticationService>().getUser().uid)
      return Container();
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(
          MediaQuery.of(context).size.width * 0.90,
          MediaQuery.of(context).size.height * 0.06,
        ),
        primary: Colors.green,
        backgroundColor: Colors.transparent,
        side: BorderSide(
          width: 1.0,
          color: Colors.green,
          style: BorderStyle.solid,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EditEvent(
              event: event,
            ),
          ),
        );
      },
      child: Text("Edit event"),
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
                if (snapshot.hasData) {
                  String photoURL = snapshot.data.pfp;
                  _image = photoURL != null
                      ? Image.network(photoURL,
                          width: 150.0, height: 150.0, fit: BoxFit.contain)
                      : Image.asset("assets/images/default_pfp.jpg",
                          width: 150.0, height: 150.0, fit: BoxFit.contain);
                }
                return NestedScrollView(
                  headerSliverBuilder: _buildHeader,
                  body: ListView(
                    children: [
                      _buildEventImage(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      _buildEventName(),
                      Card(
                        elevation: 0.3,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            snapshot.hasData
                                ? _buildOrganiserRow(snapshot.data)
                                : Container(),
                            _buildInfoRow(Icons.calendar_today, "Date",
                                event.date.toString()),
                            event.location != null
                                ? _buildInfoRow(Icons.location_pin, "Location",
                                    event.location)
                                : _buildInfoRow(
                                    Icons.public, "Online Event", ""),
                            event.facebookId != null
                                ? GestureDetector(
                                    child: _buildInfoRow(
                                      Icons.face,
                                      "Facebook",
                                      "https://www.facebook.com/events/${event.facebookId}",
                                    ),
                                    onTap: () {
                                      _launchURL(
                                          "https://www.facebook.com/events/${event.facebookId}");
                                    },
                                  )
                                : Container(),
                            _buildEditEventButton(snapshot),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                          ],
                        ),
                      ),
                      _buildEventDescription(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                );
            }
          }),
    );
  }
}
