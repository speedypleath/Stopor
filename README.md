# Stopor
Android/IOS application written in Java that helps you find events and organize events.

# App description
## 1. User stories
  1. As a user, I want to be able to search for events
  2. As a user, I want to be notified when an event I follow is edited
  3. As a user, I want to be able to follow artists
  4. As a user, I want to be notified when 24 hours before an event
  5. As an artist/organiser, I want to be able to post comments on my event
  6. As a user I want to be able to save events
  7. As a user/tourist, I want to be able to find events near me
  8. As a artist I want my events to be categorised by genre
  9. As a user, I want to be notified when an artist will organise an event near me
  10. As an organizer, I want to be able to plan an event
  11. As a user/tourist I want to know the location of an event
  12. As an organizer I want to be able to edit an event
  13. As an artist/venue manager/organiser I want to be able to add a description to my events
  14. As a user, I want to be able to link my spotify/facebook account

## 2. Backlog
  We monitorized our backlog creation using Jira. 

### Boards
![Boards](https://user-images.githubusercontent.com/61271015/121254045-7fdf3300-c8b2-11eb-9ddf-0531f40fabd8.png)
### Roadmap
![Roadmap](https://user-images.githubusercontent.com/61271015/121254054-81a8f680-c8b2-11eb-9870-0ec465dc5836.png)
### First sprint
![First sprint](https://user-images.githubusercontent.com/61271015/121254075-866daa80-c8b2-11eb-9829-24a8e30ccfc5.png)

## 3. Features List
  * Syncronize Facebook events
  * Syncronize Spotify artists
  * Search event, artist, user
  * Follow event, artist, user
  * Filter main screen by top events, followed and nearby
  * Add/Edit event
  * Update account info
# UML diagram
![Software_Design](https://user-images.githubusercontent.com/61271015/121544753-a0260380-ca12-11eb-9b58-3cafba77557b.png)

## 4. Screens
  ### News feed 
  <img src="https://user-images.githubusercontent.com/61271015/121922044-43905480-cd42-11eb-8463-d597e2832251.jpeg" width="350" height="700" />
  
  ### Settings
  <img src="https://user-images.githubusercontent.com/61271015/121922874-08425580-cd43-11eb-93c8-136bf481c003.jpeg" width="350" height="700" />
  <img src="https://user-images.githubusercontent.com/61271015/121922880-0a0c1900-cd43-11eb-90c4-eb342f4ba086.jpeg" width="350" height="700" />

  ### Add event
  <img src="https://user-images.githubusercontent.com/61271015/121924112-47bd7180-cd44-11eb-92fe-5b37373acb40.jpeg"  width="350" height="700"/>
  <img src="https://user-images.githubusercontent.com/61271015/121923437-9ae2f480-cd43-11eb-9e84-07c2c7c16c43.jpeg"  width="350" height="700"/>
  <img src="https://user-images.githubusercontent.com/61271015/121923452-9ddde500-cd43-11eb-917e-2741e9c9f9dd.jpeg" width="350" height="700" />
  <img src="https://user-images.githubusercontent.com/61271015/121923585-c2d25800-cd43-11eb-9df8-4def795c55a3.jpeg" width="350" height="700" />
  
  ### View event
  <img src="https://user-images.githubusercontent.com/61271015/121923754-e7c6cb00-cd43-11eb-806f-c08d107e0c39.jpeg"  width="350" height="700"/>
  <img src="https://user-images.githubusercontent.com/61271015/121923757-e8f7f800-cd43-11eb-90f3-2aacbc4ee633.jpeg" width="350" height="700" />
  <img src="https://user-images.githubusercontent.com/61271015/121923768-ebf2e880-cd43-11eb-8561-8cbc77668049.jpeg" width="350" height="700" />

  ### Search page
  <img src="https://user-images.githubusercontent.com/61271015/121924020-307e8400-cd44-11eb-9ba2-8977c23bca9d.jpeg" width="350" height="700" />

# Design patterns
## Singleton (Factory Constructor)
```dart
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }
```

## Provider
in main.dart
```dart
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (context) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
```
in authentication_wrapper.dart
```dart
class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) return BottomNav();
    return LoginScreen();
  }
}
```

## Strategy pattern
```dart
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
      var genres = new Map<String, bool>.from(data["genres"]);
      return new Artist(
        id: id,
        name: data["name"],
        spotifyId: data["spotifyId"],
        genres: genres,
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

```
# Source control
  * [Branches](https://github.com/speedypleath/Stopor/branches)
  * [Commits](https://github.com/speedypleath/Stopor/commits/main)

# Unit testing
  Unit testing security rules for firestore
 ### Authentication 
 ```javascript
 describe("Authentication", () => {
    it("Can't read from database if not authenticated", async () => {
        const db = getFirestore();
        const testDoc = db.collection("randomCollection").doc("testDoc");
        await firebase.assertFails(testDoc.get());
    });

    it("Can't write to database if not authenticated", async () => {
        const db = firebase.initializeTestApp({ projectId: PROJECT_ID }).firestore();
        const testDoc = db.collection("randomCollection").doc("testDoc");
        await firebase.assertFails(testDoc.set({ foo: "bar" }));
    });

    it("Can't read from database if authenticated doesn't exist", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("randomCollection").doc("testDoc");
        await firebase.assertFails(testDoc.get());
    });

    it("Can read from database if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("randomCollection").doc("testDoc");
        const userDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(userDoc.set({userId: "speedypleath"}));
        await firebase.assertSucceeds(testDoc.get());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await testDoc.delete();
    });
});
```
### Users
```javascript
describe("Users", () => {
    it("Can write user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath"}));
    });

    it("Can't write user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("anotherTestDoc");
        await firebase.assertFails(testDoc.set({ userId: "foo" }));
    });

    it("Can't modify user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertFails(testDoc.update({ userId: "speedypleath" }));
    });

    it("Can modify user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", userId: "speedypleath"}));
    });

    it("Can't delete user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.delete());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath"}));
    });
});

```

### Events
```javascript
describe("Events", () => {
    it("Can write to events if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.set({organiser: "speedypleath", facebookId: "123"}));
    });

    it("Can't modify event if authenticated user is not the owner of requested event", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertFails(testDoc.update({ foo: "bar" }));
    });

    it("Can modify event if authenticated user is the owner of requested event", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", facebookId: "123", organiser: "speedypleath"}));
    });

    it("Can't delete event if authenticated user is not the owner of requested event", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete event if authenticated user is the owner of requested event", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.delete());
    });
});
```
### Artists
```javascript
describe("Artists", () => {
    it("Can write to artist if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath", spotifyId: "123"}));
    });

    it("Can't modify artist authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertFails(testDoc.update({ foo: "bar" }));
    });

    it("Can modify artist if authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", spotifyId: "123", organiser: "speedypleath"}));
    });

    it("Can't delete artist if authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete artist if authenticated user id is equal to artist's organiser", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.delete());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await testDoc.delete();
    });
});
```
### Results
![image](https://user-images.githubusercontent.com/61271015/121257490-6cce6200-c8b6-11eb-852f-a13da31c6314.png)

# Bug reporting
[Fixed issues](https://github.com/speedypleath/Stopor/issues?q=is%3Aissue+is%3Aclosed)

# Build tools
Stopor is developed using flutter, which has a Gradle-based building tool. There are two options available to build the app:
  1. Build an app bundle
     ```console
     flutter build appbundle
     ```
  2. Build an APK
     ```console
     flutter build apk --split-per-abi
     ```
Flutter can also install an APK directly on a connected Android device, using
   ```console
   flutter install
   ```
