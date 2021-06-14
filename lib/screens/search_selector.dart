import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:stopor/api_keys.dart';
import 'package:stopor/database/database_service.dart';

class ArtistsSelect extends SearchDelegate<String> {
  ArtistsSelect(String eventId) {
    this._eventId = eventId;
  }

  String _eventId;
  final DatabaseService _databaseService = new DatabaseService();

  Future<AlgoliaQuerySnapshot> _initializeQuery() {
    Algolia algolia = APIKeys.algolia;
    AlgoliaQuery searchQuery = algolia
        .index('stopor')
        .facetFilter("documentType: artist")
        .query(query);
    return searchQuery.getObjects();
  }

  TextInputAction get textInputAction => super.textInputAction;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //Leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: _initializeQuery(),
          builder: (BuildContext context,
              AsyncSnapshot<AlgoliaQuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading....');
                break;
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                      ),
                      itemCount: snapshot.data.hits.length,
                      itemBuilder: (context, index) {
                        final AlgoliaObjectSnapshot result =
                            snapshot.data.hits[index];
                        String photoURL = result.data["image"];
                        var image = photoURL != null
                            ? NetworkImage(photoURL)
                            : AssetImage("assets/images/default_pfp.jpg");
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: image,
                          ),
                          title: Text(result.data["name"]),
                          onTap: () {
                            _databaseService.addArtistToEvent(
                                result.data["objectID"], _eventId);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                }
            }
          },
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
