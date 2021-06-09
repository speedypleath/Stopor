import 'package:algolia/algolia.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import "../extension/string_extension.dart";
import 'package:stopor/util/set_overlay.dart';
import 'package:provider/provider.dart';
import '../api_keys.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void initState() {
    _search();
    setOverlayWhite();
    super.initState();
  }

  TextEditingController _searchText = TextEditingController(text: "");
  List<AlgoliaObjectSnapshot> _results = [];
  bool _searching = false;
  String _fieldToSearch = "all";
  String _text = "";
  _search() async {
    setState(() {
      _searching = true;
    });

    Algolia algolia = APIKeys.algolia;
    AlgoliaQuery query;
    if (_fieldToSearch == "all")
      query = algolia.instance.index('stopor');
    else
      query = algolia.instance
          .index('stopor')
          .filters("documentType: $_fieldToSearch");
    query = query.query(_text);

    _results = (await query.getObjects()).hits;

    setState(() {
      _searching = false;
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            _searchText.clear();
          },
        ),
      ],
      title: TextField(
        autofocus: true,
        controller: _searchText,
        onChanged: (value) {
          _text = value;
          _search();
        },
      ),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: DefaultTabController(
            length: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Text("All"),
                  Text("Events"),
                  Text("Artists"),
                  Text("Users")
                ],
                indicator: BubbleTabIndicator(
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  indicatorHeight: 40,
                  indicatorColor: Theme.of(context).accentColor,
                ),
                onTap: (index) {
                  switch (index) {
                    case 0:
                      _fieldToSearch = "all";
                      break;
                    case 1:
                      _fieldToSearch = "event";
                      break;
                    case 2:
                      _fieldToSearch = "artist";
                      break;
                    default:
                      _fieldToSearch = "user";
                  }
                  _search();
                },
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _searching == true
          ? Center(
              child: Text("Searching, please wait..."),
            )
          : _results.length == 0
              ? Center(
                  child: Text("No results found."),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    AlgoliaObjectSnapshot snap = _results[index];
                    String photoURL = snap.data["image"];
                    var image = photoURL != null
                        ? NetworkImage(photoURL)
                        : AssetImage("assets/images/default_pfp.jpg");
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: image,
                      ),
                      trailing:
                          IconButton(icon: Icon(Icons.star), onPressed: () {}),
                      title: Text(snap.data["name"]),
                      subtitle: Text(
                          snap.data["documentType"].toString().capitalize()),
                      onTap: () {},
                    );
                  },
                ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
