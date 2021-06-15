<<<<<<< HEAD
import 'package:algolia/algolia.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
=======
>>>>>>> f1e002485473b6f8fccef34fa63928a5ecfc15e9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/screens/news_feed.dart';
import 'package:stopor/screens/search.dart';
import 'package:stopor/screens/settings.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:provider/provider.dart';

<<<<<<< HEAD
import '../api_keys.dart';
import 'notifications.dart';

=======
>>>>>>> f1e002485473b6f8fccef34fa63928a5ecfc15e9
class BottomNav extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<BottomNav> {
  FirebaseMessaging messaging;
  @override
  void initState() {

    String photoURL = context.read<AuthenticationService>().getUser().photoURL;
    var image = photoURL != null
        ? NetworkImage(photoURL)
        : AssetImage("assets/images/default_pfp.jpg");
    setOverlayWhite();
    icons = [
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
        backgroundImage: image,
      )
    ];
    super.initState();
  }

  List<Widget> icons;

  int _currentTab = 0;

  final List _screens = [
    NewsFeed(),
    //SearchScreen(),
    Scaffold(),
    Notifications(),
    SettingsPage()
  ];

  BottomNavigationBarItem _buildToolbarIcon(int index) {
    return BottomNavigationBarItem(
        icon: Container(
            child: icons[index],
            decoration: (index == 3)
                ? new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: (_currentTab == 3)
                          ? Theme.of(context).accentColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      width: 2.0,
                    ),
                  )
                : null),
        label: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentTab,
          onTap: (int value) {
            setState(() {
              _currentTab = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).accentColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: icons
              .asMap()
              .entries
              .map(
                (MapEntry map) => _buildToolbarIcon(map.key),
              )
              .toList()),
    );
  }
}
