class User {
  String id;
  String name;
  String email;
  String facebookAuthToken;
  String spotifyAuthToken;
  String pfp;
  User({
    this.id,
    this.name,
    this.email,
    this.facebookAuthToken,
    this.spotifyAuthToken,
    this.pfp,
  });
  Map<String, Object> toJSON() {
    return {
      'name': name,
      'email': email,
      'facebookAuthToken': facebookAuthToken,
      'spotifyId': spotifyAuthToken,
      'image': pfp,
      'followersCount': 0,
      "documentType": "user",
    };
  }
}
