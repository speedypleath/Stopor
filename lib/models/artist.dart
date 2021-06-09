class Artist {
  String id;
  String name;
  String spotifyId;
  List<dynamic> genres;
  String image;
  Artist({this.id, this.name, this.spotifyId, this.genres, this.image});
  Map<String, Object> toJSON() {
    return {
      'name': name,
      'genres': genres,
      'image': image,
      'sporifyId': spotifyId,
      'followersCount': 0,
      "documentType": "artist",
    };
  }
}
