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
    Icons.star,
  ),
  Icon(
    Icons.notifications,
  ),
  CircleAvatar(
    radius: 12.0,
  )
];
