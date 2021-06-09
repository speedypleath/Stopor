import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }

  final geo = Geoflutterfire();

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Event> _followedEvents = [];
  String _uid;

  Future<String> uploadPic(image) async {
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    TaskSnapshot uploadTask = await ref.putFile(File(image));
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadEvent(Event event) async {
    firestore.collection('events').add(event.toJSON());
  }

  Future getNearbyEventList(pageKey, pageSize, uid, latitude, longitude) async {
    try {
      _uid = uid;
      await getFollowedEventList(uid);
      GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
      List<String> followedEvents =
          _followedEvents.map((e) => e.id).cast<String>().toList();
      print(followedEvents);
      var query;
      if (pageKey != "") {
        var docRef = firestore.collection('events').doc(pageKey);
        var snapshot = await docRef.get();
        query = firestore
            .collection('events')
            .startAfterDocument(snapshot)
            .limit(pageSize);
      } else {
        query = firestore.collection('events').limit(pageSize);
      }
      var geoRef = geo
          .collection(collectionRef: query)
          .within(center: center, radius: 10, field: 'location.position');

      List<Event> events = [];
      try {
        await geoRef.forEach((List<DocumentSnapshot> documentList) {
          documentList.forEach((DocumentSnapshot doc) async {
            Event event = await mapToEvent(doc.data(), doc.id);
            events.add(event);
          });
        }).timeout(Duration(seconds: 1));
      } catch (e) {
        return events;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Event>> getFollowedEventList(uid) async {
    try {
      if (_followedEvents.isNotEmpty) return _followedEvents;
      if (_uid == null) _uid = uid;
      var events = await firestore
          .collection('events')
          .where('followers.$uid', isEqualTo: true)
          .get();

      _followedEvents = await mapToEventList(events.docs);
      return _followedEvents;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Event>> getEventList(pageKey, pageSize, uid) async {
    try {
      _uid = uid;
      await getFollowedEventList(uid);
      List<String> followedEvents =
          _followedEvents.map((e) => e.id).cast<String>().toList();
      print(followedEvents);
      var events;
      if (pageKey != "") {
        var docRef = firestore.collection('events').doc(pageKey);
        var snapshot = await docRef.get();
        events = firestore.collection('events');

        if (followedEvents.isNotEmpty)
          events = events
              .where("documentId", whereNotIn: followedEvents)
              .orderBy("documentId");

        events = await events
            .orderBy("followersCount")
            .startAfterDocument(snapshot)
            .limit(pageSize)
            .get();
      } else {
        events = await firestore.collection('events').limit(pageSize).get();
        print(events);
        if (followedEvents.isNotEmpty)
          events = await firestore
              .collection('events')
              .where("documentId", whereNotIn: followedEvents)
              .orderBy("documentId")
              .orderBy("followersCount")
              .limit(pageSize)
              .get();
        else
          events = await firestore
              .collection('events')
              .orderBy("followersCount")
              .limit(pageSize)
              .get();
      }
      List<Event> eventList = await mapToEventList(events.docs);
      return eventList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future mapToEventList(data) async {
    List<Event> eventObjects = [];
    await data.forEach((element) async {
      Event event = await mapToEvent(element.data(), element.id);
      eventObjects.add(event);
    });
    return eventObjects;
  }

  Future<Event> mapToEvent(data, id) async {
    String organiser = data["organiser"];
    bool isOnline;
    String location;
    if (data["location"] == null)
      location = "";
    else
      location = data["location"]["name"];
    if (data["isOnline"] == null)
      isOnline = false;
    else
      isOnline = data["isOnline"];
    String facebookId = data["facebookId"] == null ? "" : data["facebookId"];
    try {
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

  Future<void> setUserSpotifyToken(String uid, String spotifyAuthToken) async {
    firestore
        .collection('users')
        .doc(uid)
        .update({"spotifyAuthToken": spotifyAuthToken});
  }

  Future<User> getUser(String uid) async {
    if (uid == null) return null;
    var value = await firestore.collection('users').doc(uid).get();
    if (value.exists)
      return User(
          email: value.data()["email"],
          id: uid,
          pfp: value.data()["profilePic"],
          name: value.data()["name"],
          facebookAuthToken: value.data()["authToken"],
          spotifyAuthToken: value.data()["spotifyAuthToken"]);
    else
      return null;
  }

  void followEvent(Event event, String uid) {
    _followedEvents.add(event);
    firestore
        .collection('following')
        .doc(uid)
        .collection('events')
        .add(event.toJSON());
    firestore.collection('events').doc(event.id).update({
      "followersCount": FieldValue.increment(1),
    });
  }
}
