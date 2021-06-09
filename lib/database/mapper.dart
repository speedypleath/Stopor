import 'package:stopor/models/artist.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/models/user.dart';

class Mapper {
  var map;

  setArtist() {
    map = ArtistMap().map;
  }

  setUser() {
    map = UserMap().map;
  }

  setEvent() {
    map = EventMap().map;
  }

  T cast<T>(x) => x is T ? x : null;

  Future<List<T>> mapToObjectList<T>(data) async {
    List<T> objects = [];
    try {
      await data.forEach((element) async {
        T object = cast<T>(await map(element.data(), element.id));
        objects.add(object);
      });
      return objects;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

abstract class MapStrategy {
  map(data, id);
}

class EventMap implements MapStrategy {
  Future<Event> map(data, id) async {
    try {
      String organiser = data["organiser"];
      bool isOnline;
      String location;
      if (data["location"] == null)
        location = "";
      else if (!(data['location'] is String))
        location = data["location"]["name"];
      else
        location = data["location"];
      if (data["isOnline"] == null)
        isOnline = false;
      else
        isOnline = data["isOnline"];
      String facebookId = data["facebookId"] == null ? "" : data["facebookId"];
      return new Event(
        id: id,
        description: data["description"],
        date: DateTime(2020, 9, 17, 17, 30),
        name: data["name"],
        eventImage: data["image"] != false
            ? data["image"]
            : "https://keysight-h.assetsadobe.com/is/image/content/dam/keysight/en/img/prd/ixia-homepage-redirect/network-visibility-and-network-test-products/Network-Test-Solutions-New.jpg",
        location: location,
        isOnline: isOnline,
        facebookId: facebookId,
        organiser: organiser,
      );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

class ArtistMap implements MapStrategy {
  Future<Artist> map(data, id) async {
    try {
      return new Artist(
        id: id,
        name: data["name"],
        spotifyId: data["spotifyId"],
        genres: Map<String, dynamic>.from(data["genres"]).keys.toList(),
        image: data["image"],
      );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

class UserMap implements MapStrategy {
  Future<User> map(data, id) async {
    try {
      return User(
          email: data["email"],
          id: id,
          pfp: data["profilePic"],
          name: data["name"],
          facebookAuthToken: data["authToken"],
          spotifyAuthToken: data["spotifyAuthToken"]);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
