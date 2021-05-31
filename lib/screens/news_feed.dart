import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/screens/add_event.dart';
import 'package:stopor/screens/settings.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/event_card.dart';
import 'package:provider/provider.dart';
import '../data.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsFeed();
  }
}

class _NewsFeed extends State<NewsFeed> {
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    setOverlayWhite();
    super.initState();
  }

  static const _pageSize = 5;

  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  List<dynamic> _events = [];
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
                          ? Theme.of(context).accentColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      width: 2.0,
                    ),
                  )
                : null),
        label: '');
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      DatabaseService databaseService = DatabaseService();
      final newItems = await databaseService.getEventList(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems[newItems.length - 1].id;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Widget _buildList() {
    return RefreshIndicator(
      child: PagedListView<String, Event>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Event>(
          itemBuilder: (context, item, index) => EventCard(
              event: item,
              button: ElevatedButton.icon(
                label: Text("Save"),
                icon: Icon(Icons.star),
                onPressed: () {
                  setState(() {
                    _events.remove(item);
                  });
                },
              )),
        ),
      ),
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: _buildList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentTab,
          onTap: (int value) {
            if (value == 3)
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SettingsPage()));
            else
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEvent()),
              ).then((value) => setOverlayWhite());
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
