import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:provider/provider.dart';
import 'event_card.dart';

class NearbyEvents extends StatefulWidget {
  NearbyEvents();
  @override
  _NearbyEventsState createState() => _NearbyEventsState();
}

class _NearbyEventsState extends State<NearbyEvents> {
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchNearbyEvents(pageKey);
    });
    super.initState();
  }

  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  final DatabaseService _database = new DatabaseService();
  String _user;
  final _pageSize = 5;
  Position _currentLocation;

  Future<void> _fetchNearbyEvents(String pageKey) async {
    try {
      _currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      DatabaseService databaseService = DatabaseService();
      final newItems = await databaseService.getNearbyEventList(
          pageKey,
          _pageSize,
          _user,
          _currentLocation.latitude,
          _currentLocation.longitude);
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

  @override
  Widget build(BuildContext context) {
    _user = context.read<AuthenticationService>().getUser().uid;
    return PagedSliverList<String, Event>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Event>(
        itemBuilder: (context, item, index) => EventCard(
            event: item,
            button: ElevatedButton.icon(
              label: Text("Save"),
              icon: Icon(Icons.star),
              onPressed: () {
                _database.followEvent(
                    _pagingController.itemList.elementAt(index), _user);
                setState(() {
                  _pagingController.itemList.removeAt(index);
                });
              },
            )),
      ),
    );
  }
}
