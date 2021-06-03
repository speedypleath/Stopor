import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/util/get_location.dart';
import 'package:stopor/util/set_overlay.dart';
import 'package:stopor/widgets/event_card.dart';
import 'package:provider/provider.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:geolocator/geolocator.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsFeed();
  }
}

class _NewsFeed extends State<NewsFeed> with TickerProviderStateMixin {
  @override
  void initState() {
    _eventListListener = (pageKey) {
      _fetchPage(pageKey);
    };
    _followedEventListener = (pageKey) {
      _fetchFollowedEvents();
    };
    _nearbyEventListener = (pageKey) {
      _fetchNearbyEvents(pageKey);
    };
    _pagingController.addPageRequestListener(_eventListListener);
    setOverlayWhite();
    controller = new TabController(length: 3, vsync: this);
    _currentLocation = getCurrentLocation();
    super.initState();
  }

  final ScrollController _homeController = ScrollController();
  var controller;
  bool _showSaveButton = true;
  static const _pageSize = 5;
  String _user;
  var _nearbyEventListener;
  var _eventListListener;
  var _followedEventListener;
  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  DatabaseService _database = new DatabaseService();
  Position _currentLocation;

  Future<void> _fetchFollowedEvents() async {
    DatabaseService databaseService = DatabaseService();
    final newItems = await databaseService.getFollowedEventList(_user);
    final nextPageKey = newItems[newItems.length - 1].id;
    _pagingController.appendPage(newItems, nextPageKey);
    _pagingController.appendLastPage([]);
  }

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

  Future<void> _fetchNearbyEvents(String pageKey) async {
    try {
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

  Widget _buildEventView(context) {
    return PagedSliverList<String, Event>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Event>(
        itemBuilder: (context, item, index) => EventCard(
            event: item,
            button: _showSaveButton
                ? ElevatedButton.icon(
                    label: Text("Save"),
                    icon: Icon(Icons.star),
                    onPressed: () {
                      _database.followEvent(
                          _pagingController.itemList.elementAt(index), _user);
                      setState(() {
                        _pagingController.itemList.removeAt(index);
                      });
                    },
                  )
                : null),
      ),
    );
  }

  _clearEventController() {
    if (_pagingController.itemList != null) _pagingController.itemList.clear();
    _pagingController.removePageRequestListener(_followedEventListener);
    _pagingController.removePageRequestListener(_eventListListener);
    _pagingController.removePageRequestListener(_nearbyEventListener);
  }

  Widget _buildTabBar(context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      flexibleSpace: DefaultTabController(
        length: 3,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          child: TabBar(
            controller: controller,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [Text("Recomended"), Text("Following"), Text("Nearby")],
            indicator: BubbleTabIndicator(
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
              indicatorHeight: 40,
              indicatorColor: Theme.of(context).accentColor,
            ),
            onTap: (index) {
              _homeController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
              if (index == 0) {
                _showSaveButton = true;
                _clearEventController();
                _pagingController.addPageRequestListener(_eventListListener);
                _pagingController.refresh();
              } else if (index == 2) {
                _showSaveButton = false;
                _clearEventController();
                _pagingController
                    .addPageRequestListener(_followedEventListener);
                _pagingController.refresh();
              } else if (index == 1) {
                // _showSaveButton = true;
                // _clearEventController();
                // _pagingController.addListener(_followedEventListener);
                // _pagingController.refresh();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _user = context.read<AuthenticationService>().getUser().uid;
    return SafeArea(
      child: RefreshIndicator(
        child: CustomScrollView(
          controller: _homeController,
          physics: ClampingScrollPhysics(),
          slivers: [_buildTabBar(context), _buildEventView(context)],
        ),
        onRefresh: () => Future.sync(
          () => {
            _pagingController.refresh(),
          },
        ),
      ),
    );
  }
}
