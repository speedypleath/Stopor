import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:stopor/screens/edit_event.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  EventCard({this.event, this.button});

  final Widget button;

  @override
  Widget build(BuildContext context) {
    var fadeInImage = FadeInImage.assetNetwork(
      image: event.eventImage,
      fit: BoxFit.fill,
      placeholder: "assets/images/thunderdome.jpg",
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset("assets/images/thunderdome.jpg", fit: BoxFit.fill);
      },
    );
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.51,
        child: Stack(children: [
          Positioned.fill(
            child: Material(
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 58,
                      child: fadeInImage,
                    ),
                    Expanded(
                        flex: 42,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 14.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                                Text(
                                  DateFormat('y MMMM d hh:mm a')
                                      .format(event.date),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey),
                                ),
                                Text(
                                  event.isOnline ?? false
                                      ? 'Online'
                                      : event.location,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ]),
                        ))
                  ],
                ),
              ),
            ),
          ),
          new Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditEvent(
                                  event: event,
                                ))),
                  ))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 0, 0),
            child: button,
          )
        ]));
  }
}
