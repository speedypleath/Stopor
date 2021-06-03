import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/models/event.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:stopor/widgets/event_list.dart';
import 'package:stopor/widgets/followed_events.dart';
import 'package:stopor/widgets/nearby_events.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsFeed();
  }
}

class _NewsFeed extends State<NewsFeed> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  List _screens = [EventList(), FollowedEvents(), NearbyEvents()];
  final ScrollController _homeController = ScrollController();
  var _currentTab = 0;
  var controller;
  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");

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
              setState(() {
                _currentTab = index;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        child: CustomScrollView(
          controller: _homeController,
          physics: ClampingScrollPhysics(),
          slivers: [_buildTabBar(context), _screens[_currentTab]],
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
