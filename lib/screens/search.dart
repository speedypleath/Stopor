import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';

class NameSearch extends SearchDelegate<String> {
  final List<String> names;
  String result;
  var controller;
  NameSearch(this.names);
  @override
  PreferredSizeWidget buildBottom(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: DefaultTabController(
          length: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: TabBar(
              controller: controller,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: [Text("All"), Text("Events"), Text("Artists")],
              indicator: BubbleTabIndicator(
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                indicatorHeight: 40,
                indicatorColor: Theme.of(context).accentColor,
              ),
              onTap: (index) {},
            ),
          ),
        ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = names.where((name) {
      return name.toLowerCase().contains(query.toLowerCase());
    });

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            suggestions.elementAt(index),
          ),
          onTap: () {
            result = suggestions.elementAt(index);
            close(context, result);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = names.where((name) {
      return name.toLowerCase().contains(query.toLowerCase());
    });

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            suggestions.elementAt(index),
          ),
          onTap: () {
            query = suggestions.elementAt(index);
          },
        );
      },
    );
  }
}
