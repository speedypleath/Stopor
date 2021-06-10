import 'package:algolia/algolia.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/database/database_service.dart';
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

  DatabaseService _databaseService = DatabaseService();
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

  bool checkIfFollowed(snap) {
    switch (snap.data["documentType"]) {
      case 'event':
        return _databaseService.isEventFollowed(snap.data["objectID"]);
        break;
      case 'artist':
        return _databaseService.isArtistFollowed(snap.data["objectID"]);
        break;
      default:
        return _databaseService.isUserFollowed(snap.data["objectID"]);
    }
  }

  Future<bool> _followEntity(snap) async {
    bool isFollowed = checkIfFollowed(snap);
    switch (snap.data["documentType"]) {
      case "event":
        isFollowed
            ? await _databaseService.unfollowEvent(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid)
            : await _databaseService.followEventWithId(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid);
        break;
      case "artist":
        isFollowed
            ? await _databaseService.unfollowArtist(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid)
            : await _databaseService.followArtist(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid);
        break;
      default:
        isFollowed
            ? await _databaseService.unfollowUser(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid)
            : await _databaseService.followUser(snap.data["objectID"],
                context.read<AuthenticationService>().getUser().uid);
    }
    setState(() {});
    return isFollowed;
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
                    bool isFollowed = checkIfFollowed(snap);
                    var image = photoURL != null
                        ? NetworkImage(photoURL)
                        : AssetImage("assets/images/default_pfp.jpg");
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: image,
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          await _followEntity(snap);
                        },
                        icon: Icon(
                          Icons.star,
                          color: isFollowed
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                        ),
                      ),
                      title: Text(snap.data["name"]),
                      subtitle: Text(
                          snap.data["documentType"].toString().capitalize()),
                    );
                  },
                ),
    );
  }
}






// added in fork

import 'languages_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings UI')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LanguagesScreen()));
                },
              ),
              SettingsTile(title: 'Environment', subtitle: 'Production', leading: Icon(Icons.cloud_queue)),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            ],
          ),
          SettingsSection(
            title: 'Secutiry',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                onToggle: (bool value) {
                  setState(() {
                    lockInBackground = value;
                  });
                },
              ),
              SettingsTile.switchTile(title: 'Use fingerprint', leading: Icon(Icons.fingerprint), onToggle: (bool value) {}, switchValue: false),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
                switchValue: true,
                onToggle: (bool value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(title: 'Open source licenses', leading: Icon(Icons.collections_bookmark)),
            ],
          )
        ],
      ),
    );
  }
}