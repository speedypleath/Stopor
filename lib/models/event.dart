class Event {
  String eventImage;
  String description;
  String name;
  DateTime date;
  bool isOnline;
  String location;
  String inviteLink;
  String facebookId;
  String id;
  String organiser;
  Event(
      {this.id,
      this.eventImage,
      this.name,
      this.date,
      this.isOnline,
      this.location,
      this.description,
      this.inviteLink,
      this.facebookId,
      this.organiser});
  Map<String, Object> toJSON() {
    return {
      'name': name,
      'description': description,
      'isOnline': isOnline,
      'date': date,
      'image': eventImage,
      'inviteLink': inviteLink,
      'location': location,
      'facebookId': facebookId,
      'followersCount': 0,
      "documentType": "event",
      'organiser': organiser,
    };
  }
}
