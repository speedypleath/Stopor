import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/models/user.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Event> _followedEvents = [];
  String _uid;

  Future<String> uploadPic(image) async {
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    TaskSnapshot uploadTask = await ref.putFile(File(image));
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadEvent(event) async {
    firestore.collection('events').add(event.toJSON());
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
        events = await firestore
            .collection('events')
            .where(FieldPath.documentId, whereNotIn: followedEvents)
            .startAfterDocument(snapshot)
            .limit(pageSize)
            .get();
      } else {
        events = await firestore
            .collection('events')
            .where(FieldPath.documentId, whereNotIn: followedEvents)
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
    bool isOnline;
    if (data["isOnline"] == null)
      isOnline = false;
    else
      isOnline = data["isOnline"];
    User organiser = await getUser(data["organiser"]);
    return new Event(
        id: id,
        description: data["description"],
        date: DateTime(2020, 9, 17, 17, 30),
        name: data["name"],
        eventImage: data["image"] != false
            ? data["image"]
            : "https://keysight-h.assetsadobe.com/is/image/content/dam/keysight/en/img/prd/ixia-homepage-redirect/network-visibility-and-network-test-products/Network-Test-Solutions-New.jpg",
        location: data["location"],
        isOnline: isOnline,
        facebookId: data["facebookId"],
        organiser: organiser);
  }

  Future<void> setUserSpotifyToken(String uid, String spotifyAuthToken) async {
    firestore
        .collection('users')
        .doc(uid)
        .update({"spotifyAuthToken": spotifyAuthToken});
  }

  Future<User> getUser(String uid) {
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).get().then((value) => User(
        email: value.data()["email"],
        id: uid,
        name: value.data()["name"],
        facebookAuthToken: value.data()["authToken"],
        spotifyAuthToken: value.data()["spotifyAuthToken"]));
  }

  void followEvent(Event event, String uid) {
    _followedEvents.add(event);
    firestore
        .collection('users')
        .doc(uid)
        .collection('events')
        .add(event.toJSON());
    firestore
        .collection('events')
        .doc(event.id)
        .update({"followers.$uid": true});
  }
}
