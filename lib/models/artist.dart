class Artist {
  String id;
  String name;
  String spotifyId;
  Map<String, bool> genres;
  String image;
  Artist({this.id, this.name, this.spotifyId, this.genres, this.image});
  Map<String, Object> toJSON() {
    return {
      'name': name,
      'genres': genres,
      'image': image,
      'spotifyId': spotifyId,
      'followersCount': 0,
      "documentType": "artist",
    };
  }
}
