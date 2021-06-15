import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:provider/provider.dart';
import 'package:stopor/screens/notifications.dart';
import 'event_card.dart';

class EventList extends StatefulWidget {
  EventList();
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  _EventListState();
  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  final DatabaseService _database = new DatabaseService();
  String _user;
  final int _pageSize = 5;
  Future<void> _fetchPage(String pageKey) async {
    try {
      DatabaseService databaseService = DatabaseService();
      final newItems =
          await databaseService.getEventList(pageKey, _pageSize, _user);
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
<<<<<<< HEAD
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
                Notify(item.date,item.name,item.eventImage);
              },
            )),
=======
        itemBuilder: (context, item, index) => item != null
            ? EventCard(
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
                ),
              )
            : Container(),
>>>>>>> f1e002485473b6f8fccef34fa63928a5ecfc15e9
      ),
    );
  }
}
