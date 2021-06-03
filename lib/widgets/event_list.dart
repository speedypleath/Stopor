import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:provider/provider.dart';
import 'event_card.dart';

class EventList extends StatefulWidget {
  PagingController<String, Event> pagingController;
  bool showSaveButton;
  EventList({this.pagingController, this.showSaveButton});
  @override
  _EventListState createState() => _EventListState(
      pagingController: pagingController, showSaveButton: showSaveButton);
}

class _EventListState extends State<EventList> {
  @override
  void initState() {
    super.initState();
  }

  _EventListState({this.pagingController, this.showSaveButton});

  PagingController<String, Event> pagingController;
  bool showSaveButton;
  DatabaseService _database = new DatabaseService();
  @override
  Widget build(BuildContext context) {
    String _user = context.read<AuthenticationService>().getUser().uid;
    return PagedSliverList<String, Event>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<Event>(
        itemBuilder: (context, item, index) => EventCard(
            event: item,
            button: showSaveButton
                ? ElevatedButton.icon(
                    label: Text("Save"),
                    icon: Icon(Icons.star),
                    onPressed: () {
                      _database.followEvent(
                          pagingController.itemList.elementAt(index), _user);
                      setState(() {
                        pagingController.itemList.removeAt(index);
                      });
                    },
                  )
                : null),
      ),
    );
  }
}
