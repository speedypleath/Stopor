import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/event.dart';

List<Event> events = [
  Event(
    eventImage: 'assets/images/dark_lab.jpg',
    name: 'Dark_LAB pres: THE RELAUNCH',
    date: DateTime(2020, 9, 17, 17, 30),
    isOnline: true,
  ),
  Event(
    eventImage: 'assets/images/dominator.jpg',
    name: 'Dominator Festival 2022 | Official Art of Dance & Q-Dance event',
    date: DateTime(2020, 9, 17, 17, 30),
    location: "Eersel",
  ),
  Event(
    eventImage: 'assets/images/primavera.png',
    name: 'Primavera Sound 2021 Barcelona',
    date: DateTime(2020, 9, 17, 17, 30),
    location: "Barcelona",
  ),
  Event(
    eventImage: 'assets/images/thunderdome.jpg',
    name: 'Thunderdome at Mysteryland 2021',
    date: DateTime(2020, 9, 17, 17, 30),
    isOnline: true,
  )
];

List<Widget> icons = [
  Icon(
    Icons.home,
  ),
  Icon(
    Icons.search,
  ),
  Icon(
    Icons.notifications,
  ),
  CircleAvatar(
    radius: 12.0,
    backgroundImage: NetworkImage(
        "https://scontent.fotp3-2.fna.fbcdn.net/v/t1.6435-9/145719669_1128044897627163_8034789827807243572_n.jpg?_nc_cat=100&ccb=1-3&_nc_sid=09cbfe&_nc_ohc=39oySmw5pNYAX9g7WSN&_nc_ht=scontent.fotp3-2.fna&oh=00caf9a84cb5621f962559ead06afbf8&oe=609EF30B"),
  ),
];
