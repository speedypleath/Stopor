import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/widgets/event_card.dart';
import 'package:provider/provider.dart';
import '../data.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeed createState() => _NewsFeed();
}

class _NewsFeed extends State<NewsFeed> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  int _currentTab = 0;

  BottomNavigationBarItem _buildToolbarIcon(int index) {
    return BottomNavigationBarItem(
        icon: Container(
            child: icons[index],
            decoration: (index == 3)
                ? new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: (_currentTab == 3)
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      width: 2.0,
                    ),
                  )
                : null),
        label: '');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<DatabaseService>().getEventList(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            Widget child;
            child = Scaffold(
              body: ListView(
                children: <Widget>[
                  Column(
                    children: [
                      for (var event in snapshot.data) EventCard(event)
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthenticationService>().signOut();
                    },
                    child: Text("Sign out"),
                  )
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentTab,
                  onTap: (int value) {
                    setState(() {
                      _currentTab = value;
                    });
                  },
                  unselectedItemColor: Colors.grey,
                  selectedItemColor: Theme.of(context).primaryColor,
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
            return child;
          }
        });
  }
}
