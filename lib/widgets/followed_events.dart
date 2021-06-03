import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:provider/provider.dart';
import 'event_card.dart';

class FollowedEvents extends StatefulWidget {
  FollowedEvents();
  @override
  _FollowedEventsState createState() => _FollowedEventsState();
}

class _FollowedEventsState extends State<FollowedEvents> {
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchFollowedEvents();
    });
    super.initState();
  }

  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  final DatabaseService _database = new DatabaseService();
  String _user;
  Future<void> _fetchFollowedEvents() async {
    DatabaseService databaseService = DatabaseService();
    final newItems = await databaseService.getFollowedEventList(_user);
    final nextPageKey = newItems[newItems.length - 1].id;
    _pagingController.appendPage(newItems, nextPageKey);
    _pagingController.appendLastPage([]);
  }

  @override
  Widget build(BuildContext context) {
    _user = context.read<AuthenticationService>().getUser().uid;
    return PagedSliverList<String, Event>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Event>(
        itemBuilder: (context, item, index) => EventCard(
          event: item,
        ),
      ),
    );
  }
}
