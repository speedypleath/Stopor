import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stopor/models/event.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> uploadPic(image) async {
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    TaskSnapshot uploadTask = await ref.putFile(File(image));
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadEvent(event) async {
    firestore.collection('events').add(event.toJSON());
  }

  Future getEventList() async {
    try {
      var events = await firestore.collection('events').get();
      var data = events.docs.map((e) => e.data());
      List<Event> eventObjects = [];
      data.forEach((element) {
        Event event = new Event(
            description: element["description"],
            date: DateTime(2020, 9, 17, 17, 30),
            name: element["name"],
            eventImage: element["image"] != false
                ? element["image"]
                : "https://keysight-h.assetsadobe.com/is/image/content/dam/keysight/en/img/prd/ixia-homepage-redirect/network-visibility-and-network-test-products/Network-Test-Solutions-New.jpg",
            location: element["location"],
            isOnline: element["isOnline"] == null ? false : true,
            facebookId: element["facebookId"]);
        eventObjects.add(event);
      });
      return eventObjects;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
