import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stopor/models/event.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService(this._firestore);

  Stream<FirebaseFirestore> get snapshotInSync => _firestore.snapshotsInSync();

  Future getEventList() async {
    try {
      var events = await FirebaseFirestore.instance.collection('events').get();
      var data = events.docs.map((e) => e.data());
      List<Event> eventObjects = [];
      data.forEach((element) {
        Event event = new Event(
            date: DateTime(2020, 9, 17, 17, 30),
            name: element["name"],
            eventImage: element["image"],
            location: element["location"]);
        eventObjects.add(event);
      });
      return eventObjects;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
