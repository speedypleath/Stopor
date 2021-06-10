import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stopor/models/artist.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'mapper.dart';

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
  List<Artist> _followedArtists = [];
  List<User> _followedUsers = [];
  String _uid;
  Mapper _mapper = Mapper();

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
            .where("documentId", whereNotIn: followedEvents)
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
            _mapper.setEvent();
            Event event = await _mapper.map(doc.data(), doc.id);
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
      var events = await firestore
          .collection('following')
          .doc(uid)
          .collection('events')
          .get();

      _mapper.setEvent();
      _followedEvents = await _mapper.mapToObjectList<Event>(events.docs);
      return _followedEvents;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Artist>> getFollowedArtistList(uid) async {
    try {
      var artists = await firestore
          .collection('following')
          .doc(uid)
          .collection('artists')
          .get();
      _mapper.setArtist();
      _followedArtists = await _mapper.mapToObjectList<Artist>(artists.docs);
      print(_followedArtists);
      return _followedArtists;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<User>> getFollowedUserList(uid) async {
    try {
      var users = await firestore
          .collection('following')
          .doc(uid)
          .collection('users')
          .get();
      _mapper.setUser();
      _followedUsers = await _mapper.mapToObjectList<User>(users.docs);
      return _followedUsers;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Event> getEvent(eventId) async {
    var value = await firestore.collection('events').doc(eventId).get();
    _mapper.setEvent();
    if (value.exists)
      return _mapper.map(value.data(), value.id);
    else
      return null;
  }

  Future<List<Event>> getEventList(pageKey, pageSize, uid) async {
    try {
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
      _mapper.setEvent();
      var eventList = await _mapper.mapToObjectList<Event>(events.docs);
      return eventList;
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
          pfp: value.data()["image"],
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
        .doc(event.id)
        .set(event.toJSON());
    firestore.collection('events').doc(event.id).update({
      "followersCount": FieldValue.increment(1),
    });
  }

  Future<void> followEventWithId(String eventId, String uid) async {
    DocumentSnapshot snap =
        await firestore.collection('events').doc(eventId).get();
    firestore.collection('events').doc(eventId).update({
      "followersCount": FieldValue.increment(1),
    });
    _mapper.setEvent();
    Event event = await _mapper.map(snap.data(), snap.id);
    followEvent(event, uid);
  }

  Future<void> unfollowEvent(String eventId, String uid) async {
    _followedEvents.removeWhere((element) => element.id == eventId);
    firestore
        .collection('following')
        .doc(uid)
        .collection('events')
        .doc(eventId)
        .delete();
    firestore.collection('events').doc(eventId).update({
      "followersCount": FieldValue.increment(-1),
    });
  }

  Future<void> followArtist(String artistId, String uid) async {
    DocumentSnapshot snap =
        await firestore.collection('artists').doc(artistId).get();
    _mapper.setArtist();
    Artist artist = await _mapper.map(snap.data(), snap.id);
    _followedArtists.add(artist);
    firestore
        .collection('following')
        .doc(uid)
        .collection('artists')
        .doc(artistId)
        .set(artist.toJSON());
    firestore.collection('artists').doc(artistId).update({
      "followersCount": FieldValue.increment(1),
    });
  }

  Future<void> unfollowArtist(String artistId, String uid) async {
    firestore
        .collection('following')
        .doc(uid)
        .collection('artists')
        .doc(artistId)
        .delete();
    _followedArtists.removeWhere((element) => element.id == artistId);
    firestore.collection('artists').doc(artistId).update({
      "followersCount": FieldValue.increment(-1),
    });
  }

  Future<void> followUser(String followdUserId, String uid) async {
    DocumentSnapshot snap =
        await firestore.collection('users').doc(followdUserId).get();
    _mapper.setUser();
    User user = await _mapper.map(snap.data(), snap.id);
    _followedUsers.add(user);
    firestore
        .collection('following')
        .doc(uid)
        .collection('users')
        .doc(followdUserId)
        .set(user.toJSON());
    firestore.collection('users').doc(followdUserId).update({
      "followersCount": FieldValue.increment(1),
    });
  }

  Future<void> unfollowUser(String followdUserId, String uid) async {
    firestore
        .collection('following')
        .doc(uid)
        .collection('users')
        .doc(followdUserId)
        .delete();
    _followedUsers.removeWhere((element) => element.id == followdUserId);
    firestore.collection('users').doc(followdUserId).update({
      "followersCount": FieldValue.increment(-1),
    });
  }

  bool isEventFollowed(String eventId) {
    for (Event event in _followedEvents) if (event.id == eventId) return true;
    return false;
  }

  bool isArtistFollowed(String artistId) {
    for (Artist artist in _followedArtists)
      if (artist.id == artistId) return true;
    return false;
  }

  bool isUserFollowed(String userId) {
    for (User user in _followedUsers) if (user.id == userId) return true;
    return false;
  }

  void initialize(uid) {
    _uid = uid;
    if (uid == null) {
      _followedArtists = [];
      _followedEvents = [];
      _followedUsers = [];
    }
    getFollowedEventList(_uid);
    getFollowedArtistList(_uid);
    getFollowedUserList(_uid);
  }
}
